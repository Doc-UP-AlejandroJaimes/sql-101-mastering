#!/usr/bin/env python3
"""
Simplified SQL Pipeline Script
Execute SQL files in sequential order
"""
import psycopg2
import sys
import os
import argparse

# ============================================
# CONFIGURATION - EDIT HERE ONLY
# ============================================

SQL_FILES = [
    '01-create-database.sql',
    '02-create-tables.sql',
    '03-alter-tables.sql'
]

# ============================================
# DO NOT EDIT BELOW THIS LINE
# ============================================

def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Execute SQL files in order')
    parser.add_argument('--sql-dir', required=True, help='Directory containing SQL files (e.g., ../ddl)')
    parser.add_argument('--user', required=True, help='PostgreSQL username')
    parser.add_argument('--password', required=True, help='PostgreSQL password')
    parser.add_argument('--host', default='localhost', help='PostgreSQL host (default: localhost)')
    parser.add_argument('--port', default=5433, type=int, help='PostgreSQL port (default: 5433)')
    parser.add_argument('--database', default='smarthdb', help='Target database name (default: smarthdb)')
    parser.add_argument('--create-script', default=False, help='Create database if its necessary.')
    return parser.parse_args()

def connect_postgres(host, port, user, password, dbname='postgres'):
    """Create a connection to PostgreSQL"""
    try:
        conn = psycopg2.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            dbname=dbname
        )
        print(f"Connected to PostgreSQL - {dbname}")
        return conn
    except Exception as e:
        print(f"Error connecting to PostgreSQL: {e}")
        sys.exit(1)

def parse_sql_file(filepath):
    """Parse SQL file and split into statements"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            sql = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Using latin-1 encoding for {filepath}")
        with open(filepath, 'r', encoding='latin-1') as f:
            sql = f.read()
    
    statements = []
    buffer = ""
    
    for line in sql.splitlines():
        line = line.strip()
        # Skip empty lines and comments
        if not line or line.startswith('--'):
            continue
        
        buffer += " " + line
        
        # Check if statement ends with semicolon
        if line.endswith(";"):
            statements.append(buffer.strip())
            buffer = ""
    
    return statements

def execute_statements(conn, statements):
    """Execute SQL statements"""
    with conn.cursor() as cur:
        for i, statement in enumerate(statements, 1):
            try:
                print(f"  Executing statement {i}/{len(statements)}")
                cur.execute(statement)
            except Exception as e:
                print(f"  Error in statement {i}: {e}")
                raise

def execute_custom_script(filepath, message, sql_file, path_dir, host, port, user, password, dbname):
    """Execute script creation
    """
    print(f"-----{message}-----")
    print(f"Reading: {sql_file} located in {path_dir}")
    statements = parse_sql_file(filepath)
    ############ START EXECUTION ###########
    try:
        print(f"Connection Properties: User:{user}\nDatabase:{dbname}\nHost:{host}")
        conn = connect_postgres(host, port, user, password, dbname)
        conn.autocommit = True
        print(f"Execute: {len(statements)} statements on {dbname} database")
        execute_statements(conn, statements)
    except psycopg2.OperationalError as e:
        print(f"Connection error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)
    finally:
        conn.close()
    
    
def main():
    args = parse_arguments()
    sql_dir = args.sql_dir
    
    print("############### Starting SQL pipeline ###################")
    
    # Validate directory exists
    if not os.path.isdir(sql_dir):
        print(f"Error: Directory not found - {sql_dir}")
        sys.exit(1)
    
    try:
        # Step 1. Check if its creation file
        if args.create_script:
            filepath = os.path.join(sql_dir, SQL_FILES[0])
            execute_custom_script(filepath,'Database Creation',SQL_FILES[0],sql_dir,
                                  args.host, args.port, args.user, args.password, dbname='postgres')
        else:
            sql_scripts_descriptions = ['Tables Creation', 'Alter Tables']
            for i in range(len(SQL_FILES[1:])):
                
                filepath = os.path.join(sql_dir, SQL_FILES[1:][i])
                execute_custom_script(filepath, sql_scripts_descriptions[i],SQL_FILES[1:][i],sql_dir,
                                      args.host, args.port, args.user, args.password, args.database)

        print("Pipeline completed successfully")
        
    except psycopg2.OperationalError as e:
        print(f"Connection error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()