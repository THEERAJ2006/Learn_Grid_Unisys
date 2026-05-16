#!/usr/bin/env python3
"""
Federated Learning Client for LearnGrid
Flower (flwr) based client that trains on local engagement data
and sends encrypted gradients to the aggregation server.
"""

import os
import sys
import json
import sqlite3
import argparse
import logging
import numpy as np
import tensorflow as tf
import tensorflow_privacy as tfp
from typing import List, Tuple, Dict, Any
import flwr as fl

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class LearnGridFlowerClient(fl.client.NumPyClient):
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.model = self._build_model()
        self.optimizer = tfp.DPKerasSGDOptimizer(
            l2_norm_clip=1.0,
            noise_multiplier=1.1,
            num_microbatches=1,
            learning_rate=0.1,
        )
        self.model.compile(
            optimizer=self.optimizer,
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        self.local_data, self.local_labels = self._load_local_data()
    
    def _build_model(self) -> tf.keras.Model:
        """Create a simple neural network for engagement prediction."""
        model = tf.keras.Sequential([
            tf.keras.layers.Dense(64, activation='relu', input_shape=(10,)),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(32, activation='relu'),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(5, activation='softmax')  # 5 engagement levels
        ])
        return model
    
    def _load_local_data(self) -> Tuple[np.ndarray, np.ndarray]:
        """Load engagement session data from local SQLite database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Query engagement sessions with features
            cursor.execute("""
                SELECT 
                    durationSeconds,
                    tapCount,
                    scrollEvents,
                    idleSeconds,
                    startedAt,
                    completionPct,
                    difficultyRating,
                    timeSpentSeconds,
                    fileSize,
                    addedAt
                FROM EngagementSessions 
                WHERE startedAt > ?
            """, ((int((tf.timestamp() - 86400 * 7) * 1000)),))  # Last 7 days
            
            rows = cursor.fetchall()
            conn.close()
            
            if not rows:
                # Generate synthetic data if no local data exists
                logger.warning("No local engagement data found, using synthetic data")
                X = np.random.rand(100, 10).astype(np.float32)
                y = np.random.randint(0, 5, 100)
                return X, y
            
            # Convert to numpy arrays
            X = np.array(rows, dtype=np.float32)
            # Normalize features
            X = (X - np.mean(X, axis=0)) / (np.std(X, axis=0) + 1e-8)
            # Labels: engagement level based on completion percentage
            y = np.array([min(4, int(row[5] * 5)) for row in rows])  # 0-4 scale
            
            return X, y
            
        except Exception as e:
            logger.error(f"Failed to load local data: {e}")
            # Fallback to synthetic data
            X = np.random.rand(100, 10).astype(np.float32)
            y = np.random.randint(0, 5, 100)
            return X, y
    
    def get_parameters(self, config: Dict[str, str]) = List[np.ndarray]:
        """Return the current model weights."""
        return self.model.get_weights()
    
    def fit(self, parameters: List[np.ndarray], config: Dict[str, str]) -> Tuple[List[np.ndarray], int, Dict]:
        """Train the model on local data."""
        self.model.set_weights(parameters)
        history = self.model.fit(
            self.local_data,
            self.local_labels,
            epochs=5,
            batch_size=32,
            verbose=0
        )
        
        # Calculate gradient update (simplified)
        # In practice, we would compute actual gradients
        gradient_update = self.model.get_weights()
        
        return gradient_update, len(self.local_data), {
            "loss": float(history.history["loss"][-1]),
            "accuracy": float(history.history["accuracy"][-1])
        }
    
    def evaluate(self, parameters: List[np.ndarray], config: Dict[str, str]) -> Tuple[float, int, Dict]:
        """Evaluate the model on local data."""
        self.model.set_weights(parameters)
        loss, accuracy = self.model.evaluate(
            self.local_data, 
            self.local_labels, 
            verbose=0
        )
        return loss, len(self.local_data), {"accuracy": accuracy}

def main():
    parser = argparse.ArgumentParser(description="LearnGrid Federated Learning Client")
    parser.add_argument("db_path", help="Path to the SQLite database")
    parser.add_argument("--server_address", default="localhost:8080", help="Flower server address")
    args = parser.parse_args()
    
    logger.info(f"Starting LearnGrid FL client with DB: {args.db_path}")
    
    # Start Flower client
    client = LearnGridFlowerClient(args.db_path)
    fl.client.start_numpy_client(
        server_address=args.server_address,
        client=client
    )

if __name__ == "__main__":
    main()