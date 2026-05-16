#!/usr/bin/env python3
"""
test_db.py - Verify SQLite database schema and indexes are present.

Pulls the SQLite database from Android device (via adb) or checks local file,
then verifies the schema, tables, and performance indexes exist.

Expected tables (10 total):
  1. users
  2. content_items
  3. transcripts
  4. image_insights
  5. embeddings
  6. engagement_sessions
  7. user_progress
  8. ai_response_cache
  9. leaderboard_entries
  10. peer_devices

Expected indexes (11 total - see app_database.dart):
  1. idx_content_items_type
  2. idx_content_items_subject
  3. idx_engagement_sessions_user_id
  4. idx_embeddings_content_id
  5. idx_user_progress_user_id
  6. idx_user_progress_content_id
  7. idx_image_insights_content_id
  8. idx_transcripts_video_id
  9. idx_ai_response_cache_cache_key
  10. idx_ai_response_cache_expires_at
  11. idx_peer_devices_last_seen

Usage:
    python3 test_db.py
    python3 test_db.py --db-path "/path/to/learngrid.db"
    python3 test_db.py --adb  # Pull from Android device
    DB_PATH="/path/to/learngrid.db" python3 test_db.py

Exit codes:
    0 = Database schema verified
    1 = Database missing or schema incomplete
"""

import argparse
import json
import os
import sqlite3
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Tuple


class DatabaseVerifier:
    """Verifies SQLite database schema and indexes."""

    EXPECTED_TABLES = {
        'users',
        'content_items',
        'transcripts',
        'image_insights',
        'embeddings',
        'engagement_sessions',
        'user_progress',
        'a_i_response_cache',
        'leaderboard_entries',
        'peer_devices',
    }

    EXPECTED_INDEXES = {
        'idx_content_items_type',
        'idx_content_items_subject',
        'idx_engagement_sessions_user_id',
        'idx_embeddings_content_id',
        'idx_user_progress_user_id',
        'idx_user_progress_content_id',
        'idx_image_insights_content_id',
        'idx_transcripts_video_id',
        'idx_a_i_response_cache_cache_key',
        'idx_a_i_response_cache_expires_at',
        'idx_peer_devices_last_seen',
    }

    def __init__(self, db_path: str = None):
        """Initialize database verifier."""
        self.db_path = db_path
        self.db_connection = None
        self.results = {}

    def pull_from_adb(self) -> bool:
        """Pull learngrid.db from connected Android device."""
        try:
            # Try common paths where Flutter stores app data
            remote_paths = [
                '/data/data/com.learngrid.app/databases/learngrid.db',
                '/data/data/com.unysis.learngrid/databases/learngrid.db',
                '/data/data/learngrid/databases/learngrid.db',
            ]
            
            with tempfile.NamedTemporaryFile(delete=False, suffix='.db') as tmp:
                local_path = tmp.name
            
            found = False
            for remote_path in remote_paths:
                print(f"Attempting to pull: {remote_path}")
                try:
                    result = subprocess.run(
                        ['adb', 'pull', remote_path, local_path],
                        capture_output=True,
                        timeout=10,
                        text=True
                    )
                    if result.returncode == 0 and Path(local_path).stat().st_size > 0:
                        print(f"✓ Successfully pulled from: {remote_path}")
                        self.db_path = local_path
                        found = True
                        break
                except Exception as e:
                    print(f"  Failed: {str(e)}")
            
            if not found:
                print("✗ Could not pull database from any known path")
                return False
            
            return True
        except Exception as e:
            print(f"✗ adb error: {str(e)}")
            return False

    def connect(self) -> bool:
        """Connect to the database."""
        try:
            if not self.db_path or not Path(self.db_path).exists():
                print(f"✗ Database not found: {self.db_path}")
                return False
            
            self.db_connection = sqlite3.connect(self.db_path)
            return True
        except Exception as e:
            print(f"✗ Failed to connect to database: {str(e)}")
            return False

    def get_tables(self) -> List[str]:
        """Get list of tables in the database."""
        try:
            cursor = self.db_connection.cursor()
            cursor.execute(
                "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
            )
            return [row[0] for row in cursor.fetchall()]
        except Exception as e:
            print(f"✗ Error querying tables: {str(e)}")
            return []

    def get_indexes(self) -> List[str]:
        """Get list of indexes in the database."""
        try:
            cursor = self.db_connection.cursor()
            cursor.execute(
                "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'"
            )
            return [row[0] for row in cursor.fetchall()]
        except Exception as e:
            print(f"✗ Error querying indexes: {str(e)}")
            return []

    def verify_schema(self) -> bool:
        """Verify database schema."""
        print("Verifying SQLite database schema...")
        print()
        
        if not self.connect():
            return False
        
        print(f"Database: {self.db_path}")
        print()
        
        # Check tables
        print("Table verification:")
        actual_tables = set(self.get_tables())
        missing_tables = self.EXPECTED_TABLES - actual_tables
        extra_tables = actual_tables - self.EXPECTED_TABLES
        
        for table in sorted(self.EXPECTED_TABLES):
            if table in actual_tables:
                print(f'  ✓ {table}')
            else:
                print(f'  ✗ {table} (missing)')
        
        if extra_tables:
            print("\n  Extra tables found:")
            for table in sorted(extra_tables):
                print(f'    + {table}')
        
        all_tables_ok = len(missing_tables) == 0
        print()
        
        # Check indexes
        print("Index verification:")
        actual_indexes = set(self.get_indexes())
        missing_indexes = self.EXPECTED_INDEXES - actual_indexes
        extra_indexes = actual_indexes - self.EXPECTED_INDEXES
        
        for index in sorted(self.EXPECTED_INDEXES):
            if index in actual_indexes:
                print(f'  ✓ {index}')
            else:
                print(f'  ✗ {index} (missing)')
        
        if extra_indexes:
            print("\n  Extra indexes found:")
            for index in sorted(extra_indexes):
                print(f'    + {index}')
        
        all_indexes_ok = len(missing_indexes) == 0
        print()
        
        # Summary
        print("Summary:")
        print(f'  Tables: {len(actual_tables)}/{len(self.EXPECTED_TABLES)}')
        print(f'  Indexes: {len([i for i in actual_indexes if i in self.EXPECTED_INDEXES])}/{len(self.EXPECTED_INDEXES)}')
        
        return all_tables_ok and all_indexes_ok

    def close(self):
        """Close database connection."""
        if self.db_connection:
            self.db_connection.close()

    def generate_report(self) -> Dict:
        """Generate a JSON-serializable report."""
        tables = self.get_tables() if self.db_connection else []
        indexes = self.get_indexes() if self.db_connection else []
        
        return {
            'db_path': str(self.db_path),
            'tables_found': len(tables),
            'tables_expected': len(self.EXPECTED_TABLES),
            'indexes_found': len([i for i in indexes if i in self.EXPECTED_INDEXES]),
            'indexes_expected': len(self.EXPECTED_INDEXES),
            'missing_tables': list(self.EXPECTED_TABLES - set(tables)),
            'missing_indexes': list(self.EXPECTED_INDEXES - set(indexes)),
        }


def main():
    """Parse args and verify database."""
    parser = argparse.ArgumentParser(
        description='Verify SQLite database schema and indexes.'
    )
    parser.add_argument(
        '--db-path',
        default=os.getenv('DB_PATH'),
        help='Path to learngrid.db (fallback: DB_PATH env var)'
    )
    parser.add_argument(
        '--adb',
        action='store_true',
        help='Pull database from connected Android device via adb'
    )
    parser.add_argument(
        '--report',
        action='store_true',
        help='Output JSON report instead of text'
    )
    
    args = parser.parse_args()
    
    verifier = DatabaseVerifier(db_path=args.db_path)
    
    if args.adb:
        if not verifier.pull_from_adb():
            sys.exit(1)
    
    if not verifier.db_path:
        print("✗ No database path specified and --adb not used")
        print("Usage: python3 test_db.py --db-path /path/to/learngrid.db")
        print("  or:  python3 test_db.py --adb  (pulls from Android device)")
        sys.exit(1)
    
    try:
        if args.report:
            # Connect and generate report
            verifier.connect()
            report = verifier.generate_report()
            verifier.close()
            print(json.dumps(report, indent=2))
        else:
            # Standard text output
            all_ok = verifier.verify_schema()
            verifier.close()
            
            if not all_ok:
                sys.exit(1)
        
        sys.exit(0)
    except Exception as e:
        print(f"✗ Unexpected error: {str(e)}")
        sys.exit(1)


if __name__ == '__main__':
    main()
