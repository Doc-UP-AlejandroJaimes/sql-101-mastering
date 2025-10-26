#!/usr/bin/env python3
import os
import sys
import argparse
import psycopg2
import time
import logging
from typing import List, Optional
from psycopg2 import sql, errors
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from tqdm import tqdm

# Improved logging configuration
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('sql_pipeline')

class SQLPipeline:
    def __init__(self):
        self.args = self.parse_arguments()
        self.conn = None
        # Standard SQL files for regular scripts
        self.standard_sql_files = [
            '01-INSERT-DEPARTMENTS.sql',
            '02-INSERT-MUNICIPALITIES.sql',
            '03-INSERT-DOCUMENT-TYPES.sql',
            '04-INSERT-SPECIALTIES.sql',
            '05-INSERT-DIAGNOSES.sql',
            '06-INSERT-MEDICATIONS.sql'
        ]
        # Bulk load SQL files (from Bulk-Load directory)
        self.bulk_load_sql_files = [
            '07-INSERT-ADDRESSES.sql',
            '08-INSERT-PATIENTS.sql',
            '09-INSERT-PATIENTS-PHONE.sql',
            '10-INSERT-PATIENTS-ADDRESSES.sql',
            '11-INSERT-PATIENTS-ALLERGIES.sql',
            '12-INSERT-DOCTORS.sql',
            '13-INSERT-DOCTOR_SPECIALTIES.sql',
            '14-INSERT-DOCTOR_ADDRESSES.sql',
            '15-INSERT-ROOMS.sql',
            '16-INSERT-APPOINTMENTS.sql',
            '17-INSERT-MEDICAL_RECORDS.sql',
            '18-INSERT-RECORD-DIAGNOSES.sql',
            '19-INSERT-PRESCRIPTIONS.sql']
        self.delay_between_files = 1  # 1 second delay between files

    def parse_arguments(self):
        """Parse command line arguments with improved validation"""
        parser = argparse.ArgumentParser(description='PostgreSQL Database Pipeline')
        
        parser.add_argument('--host', default='localhost', 
                          help='PostgreSQL host (default: localhost)')
        parser.add_argument('--port', default=5433, type=int,
                          help='PostgreSQL port (default: 5433)')
        parser.add_argument('--user', required=True,
                          help='PostgreSQL username')
        parser.add_argument('--password', required=True,
                          help='PostgreSQL password')
        parser.add_argument('--db-name', default='fintech_cards',
                          help='Database name (default: fintech_cards)')
        parser.add_argument('--schema-name', default='fintech',
                          help='Schema name (default: fintech)')
        parser.add_argument('--sql-dir', default='.',
                          help='Directory containing SQL files (default: current directory)')
        parser.add_argument('--max-retries', type=int, default=3,
                          help='Max connection retries (default: 3)')
        parser.add_argument('--delay', type=float, default=1.0,
                          help='Delay between files in seconds (default: 1.0)')
        
        return parser.parse_args()

    def connect_postgres(self) -> Optional[psycopg2.extensions.connection]:
        """Create a robust PostgreSQL connection with retries"""
        for attempt in range(self.args.max_retries):
            try:
                conn = psycopg2.connect(
                    host=self.args.host,
                    port=self.args.port,
                    user=self.args.user,
                    password=self.args.password,
                    dbname=self.args.db_name,
                    connect_timeout=10
                )
                logger.info(f"Connected to PostgreSQL (attempt {attempt + 1})")
                return conn
            except (psycopg2.OperationalError, psycopg2.InterfaceError) as e:
                logger.warning(f"Connection attempt {attempt + 1} failed: {e}")
                if attempt == self.args.max_retries - 1:
                    logger.error("Max connection retries reached")
                    return None
                time.sleep(2 ** attempt)  # Exponential backoff

    def validate_sql_file(self, file_path: str) -> bool:
        """Validate SQL file exists and is readable"""
        if not os.path.exists(file_path):
            logger.error(f"File not found: {file_path}")
            return False
        
        if not os.access(file_path, os.R_OK):
            logger.error(f"File not readable: {file_path}")
            return False
            
        if os.path.getsize(file_path) == 0:
            logger.warning(f"Empty file: {file_path}")
            return False
            
        return True

    def execute_sql_file(self, file_path: str) -> bool:
        """Execute SQL file with transaction control and error handling"""
        if not self.validate_sql_file(file_path):
            return False

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                sql_commands = f.read()
        except UnicodeDecodeError:
            try:
                with open(file_path, 'r', encoding='latin-1') as f:
                    sql_commands = f.read()
            except Exception as e:
                logger.error(f"Failed to read file {file_path}: {e}")
                return False

        statements = []
        buffer = ""
        for line in sql_commands.splitlines():
            line = line.strip()
            if not line or line.startswith('--'):
                continue
            buffer += " " + line
            if line.endswith(";"):
                statements.append(buffer.strip())
                buffer = ""

        if not statements:
            logger.warning(f"No valid SQL statements found in {file_path}")
            return True

        try:
            with self.conn.cursor() as cur:
                # Progress bar for statements within the file
                with tqdm(statements, desc=f"Processing {os.path.basename(file_path)}", leave=False) as pbar_statements:
                    for statement in pbar_statements:
                        try:
                            cur.execute(statement)
                            pbar_statements.set_postfix(status="OK")
                        except errors.Error as e:
                            pbar_statements.set_postfix(status="ERROR")
                            logger.error(f"Error in statement: {e.pgerror}")
                            self.conn.rollback()
                            return False
                            
            self.conn.commit()
            logger.info(f"Successfully executed {len(statements)} statements from {file_path}")
            return True
            
        except Exception as e:
            logger.error(f"Unexpected error executing {file_path}: {e}")
            self.conn.rollback()
            return False

    def find_sql_directory(self) -> Optional[str]:
        """Locate SQL directory with fallback logic"""
        # 1. Check explicitly provided directory
        if os.path.exists(self.args.sql_dir):
            sql_dir = os.path.abspath(self.args.sql_dir)
            catalog_path = os.path.join(sql_dir, 'Catalogo')
            bulk_path = os.path.join(sql_dir, 'Bulk-Load')

            if os.path.isdir(catalog_path) and any(os.path.exists(os.path.join(catalog_path, f)) for f in self.standard_sql_files):
                return sql_dir
        
        # 2. Check standard locations
        possible_locations = [
            os.path.join(get_project_root(), 'data', 'sql'),
            os.path.join(get_project_root(), 'data'),
            os.path.join(os.path.dirname(__file__), '..', '..', '..', 'data', 'sql')
        ]
        
        for location in possible_locations:
            norm_path = os.path.normpath(location)
            if os.path.exists(norm_path):
                if any(os.path.exists(os.path.join(norm_path, f)) for f in self.standard_sql_files):
                    return norm_path
        
        return None

    def run(self):
        """Main execution flow with proper resource management"""
        logger.info("Starting SQL Pipeline")
        
        # 1. Locate SQL files
        sql_dir = self.find_sql_directory()
        if not sql_dir:
            logger.error("Could not locate SQL files directory")
            sys.exit(1)
            
        logger.info(f"Using SQL directory: {sql_dir}")
        
        # 2. Establish database connection
        self.conn = self.connect_postgres()
        if not self.conn:
            sys.exit(1)
            
        try:
            # 3. Verify schema exists
            if not self.schema_exists(self.args.schema_name):
                logger.error(f"Schema {self.args.schema_name} does not exist")
                sys.exit(1)
                
            # 4. Create combined list of all files to process
            all_files = []
            
            # Add standard SQL files first
            for sql_file in self.standard_sql_files:
                all_files.append((sql_file, os.path.join(sql_dir,'Catalogo', sql_file)))
            
            # Add bulk load SQL files (in Bulk-Load directory)
            bulk_load_dir = os.path.join(sql_dir, "Bulk-Load")
            if os.path.exists(bulk_load_dir):
                for sql_file in self.bulk_load_sql_files:
                    all_files.append((sql_file, os.path.join(bulk_load_dir, sql_file)))
            else:
                logger.warning(f"Bulk-Load directory not found at {bulk_load_dir}")
                
            # 5. Execute files with progress bar
            success_count = 0
            with tqdm(all_files, desc="Processing SQL files") as pbar_files:
                for sql_file_name, file_path in pbar_files:
                    pbar_files.set_postfix(file=sql_file_name[:15] + "...")
                    
                    if self.execute_sql_file(file_path):
                        success_count += 1
                    else:
                        logger.error(f"Failed to execute {sql_file_name}")
                        break
                    
                    # Delay between files
                    if sql_file_name != all_files[-1][0]:  # No waiting after last file
                        time.sleep(self.args.delay)
                    
            logger.info(f"Pipeline completed. {success_count}/{len(all_files)} files processed successfully")
            return success_count == len(all_files)
            
        finally:
            if self.conn:
                self.conn.close()
                logger.info("Database connection closed")

    def schema_exists(self, schema_name: str) -> bool:
        """Check if schema exists in the database"""
        try:
            with self.conn.cursor() as cur:
                cur.execute("SELECT 1 FROM pg_namespace WHERE nspname = %s", (schema_name,))
                exists = cur.fetchone() is not None
                logger.info(f"Schema exists: {exists}")
                return exists
        except Exception as e:
            logger.error(f"Error checking schema existence: {e}")
            return False

def get_project_root():
    """Returns the absolute path to the fintech-accelerator directory"""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.dirname(os.path.dirname(os.path.dirname(current_dir)))

if __name__ == "__main__":
    pipeline = SQLPipeline()
    if not pipeline.run():
        sys.exit(1)