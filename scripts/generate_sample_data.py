#!/usr/bin/env python3
"""
Sample data generator for LearnGrid engagement database
"""

import sqlite3
import random
import datetime

def generate_sample_data(db_path: str):
    """Generate sample engagement data for testing."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Create EngagementSessions table if it doesn't exist
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS EngagementSessions (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            contentId TEXT NOT NULL,
            state TEXT NOT NULL,
            durationSeconds INTEGER NOT NULL,
            tapCount INTEGER DEFAULT 0,
            scrollEvents INTEGER DEFAULT 0,
            idleSeconds INTEGER DEFAULT 0,
            startedAt INTEGER NOT NULL,
            completionPct REAL DEFAULT 0.0,
            difficultyRating INTEGER,
            timeSpentSeconds INTEGER DEFAULT 0,
            fileSize INTEGER,
            addedAt INTEGER
        )
    """)
    
    # Generate sample data for the last 30 days
    base_time = int((datetime.datetime.now() - datetime.timedelta(days=30)).timestamp() * 1000)
    
    sample_data = []
    for i in range(100):  # Generate 100 sample sessions
        session_id = f"session_{i:03d}"
        user_id = f"user_{random.randint(1, 10):02d}"
        content_id = f"content_{random.randint(1, 20):02d}"
        
        # Random engagement state
        states = ['focused', 'passive', 'fatigued', 'absent']
        state = random.choice(states)
        
        # Generate realistic values based on state
        if state == 'focused':
            duration = random.randint(300, 1800)  # 5-30 minutes
            tap_count = random.randint(10, 50)
            scroll_events = random.randint(5, 30)
            idle_seconds = random.randint(0, 60)
            completion_pct = random.uniform(0.7, 1.0)
        elif state == 'passive':
            duration = random.randint(180, 900)   # 3-15 minutes
            tap_count = random.randint(2, 15)
            scroll_events = random.randint(2, 15)
            idle_seconds = random.randint(30, 180)
            completion_pct = random.uniform(0.3, 0.7)
        elif state == 'fatigued':
            duration = random.randint(60, 300)    # 1-5 minutes
            tap_count = random.randint(1, 8)
            scroll_events = random.randint(1, 8)
            idle_seconds = random.randint(120, 300)
            completion_pct = random.uniform(0.1, 0.4)
        else:  # absent
            duration = random.randint(0, 60)      # 0-1 minute
            tap_count = random.randint(0, 3)
            scroll_events = random.randint(0, 3)
            idle_seconds = random.randint(180, 600)
            completion_pct = random.uniform(0.0, 0.2)
        
        difficulty_rating = random.randint(1, 5)
        time_spent = duration - idle_seconds
        file_size = random.randint(100000, 5000000)  # 100KB - 5MB
        added_at = base_time + random.randint(0, 30*24*60*60*1000)  # Within last 30 days
        
        sample_data.append((
            session_id, user_id, content_id, state, duration, tap_count,
            scroll_events, idle_seconds, int(added_at), completion_pct,
            difficulty_rating, time_spent, file_size, int(added_at)
        ))
    
    cursor.executemany("""
        INSERT OR REPLACE INTO EngagementSessions 
        (id, userId, contentId, state, durationSeconds, tapCount, scrollEvents, 
         idleSeconds, startedAt, completionPct, difficultyRating, timeSpentSeconds, 
         fileSize, addedAt)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, sample_data)
    
    conn.commit()
    conn.close()
    
    print(f"Generated {len(sample_data)} sample engagement sessions in {db_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 generate_sample_data.py <database_path>")
        sys.exit(1)
    
    generate_sample_data(sys.argv[1])