"""
convert_to_bulk_insert.py

Developer: Juan Alejandro Carrillo Jaimes
Brief: This file convert inserts files in bulk load files
Created at: March 28 of 2026
"""

import re
import argparse
from pathlib import Path
import os
from tqdm import tqdm
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


class ConvertBulkInsert:

    # Modify this in case of be necessary
    # The order its to important
    _SQL_FILES = [
        'orders_variety_c20260328.sql',
        'orders_items_variety_c20260328.sql',
        'shipment_orders_variety_c20260328.sql'
    ]

    def __init__(self, 
                 batch_size:int = 10000, 
                data_path:str = "../../../data/sql",
                output_dir:str = "bulk-load"):
        self._batch_size = batch_size
        self._base_path = Path(data_path)
        self._output_dir = self._base_path / output_dir
        self._create_dir_if_not_exist()
    
    def _parse_insert_line(self, line:str):
        """Extract values from an INSERT line

        Args:
            line (str): SQL line
        """
        match = re.search(r"VALUES\s*\((.*)\);", line.strip(), re.IGNORECASE)
        return match.group(1) if match else None

    def _create_dir_if_not_exist(self):
        """Create directory if it doesn't exist
        """
        os.makedirs(self._output_dir, exist_ok=True)

    def get_table_info(self, line:str):
        """Extract schema, table name and columns from an INSERT line
        
        Args:
            line (str): SQL line
        """
        
        pattern = r"INSERT INTO\s+((\w+)\.)?(\w+)\s*\((.*?)\)\s*VALUES"
        match = re.match(pattern, line, re.IGNORECASE)
        
        if match:
            schema = match.group(2)
            table = match.group(3)
            columns = match.group(4)
            
            return schema, table, columns
        
        return None, None, None
    
    def _generate_bulk_insert(self, schema:str, table:str, columns:str, 
                              values:list, output_path_file:str):
        """Generate bulk INSERT file with batched statements

        Args:
            schema (str): schema of table
            table (str): sql table
            columns (str): columns to be insert
            values (list): values separed by colon
            output_path_file (str): path to save file
        """
        total_batches = (len(values) + self._batch_size - 1) // self._batch_size

        with open(output_path_file, 'w', encoding='utf-8') as out:
            for i in tqdm(range(0, len(values),  self._batch_size), 
                        desc=f"Generating batches for {output_path_file.name}",
                        total=total_batches):
                batch = values[i:i+ self._batch_size]
                out.write("BEGIN;\n")
                out.write(f"INSERT INTO {schema}.{table} ({columns}) VALUES\n")
                out.write(",\n".join(f"({v})" for v in batch))
                out.write(";\nCOMMIT;\n\n")
        logger.info(f"Records saved successfully in {output_path_file}")

    
    def read_sql_file(self, filename:str, file_path:str, total_lines:int):
        """Read SQL files and return the complement values

        Args:
            file_path (str): filepath of the main file in the list
            total_lines (int): number of lines checked
        """
        table = None
        columns = None
        schema = None
        values_list = []
        reading_values = False

        with open(file_path, 'r', encoding='utf-8') as f:
            for line in tqdm(f, total=total_lines, desc=f'Reading {filename}', leave=False):
                line = line.strip()

                if not line:
                    continue

                if not reading_values:
                    if line.lower().startswith('insert into'):
                        schema, table, columns = self.get_table_info(line)
                        if not table or not columns:
                            logger.warning(f"Could not extract table information from {filename}")
                            break
                        reading_values = True
                    continue

                # Detect end line before clean
                is_last = line.endswith(');')

                # Clean: remove colon or dot and colon for the end
                clean = line[:-1] if line.endswith(';') else line
                clean = clean[:-1] if clean.endswith(',') else clean
                clean = clean.strip()

                # Remove external brackets
                if clean.startswith('(') and clean.endswith(')'):
                    clean = clean[1:-1]

                if clean:
                    values_list.append(clean)

                if is_last:
                    reading_values = False

        return schema, table, columns, values_list

    def convert_to_bulk_insert(self):
        """Convert SQL files with individual INSERTs to batched INSERTs
        """
        # Process SQL Files
        logger.info("Starting processing SQL files")
        for file_name in tqdm(self._SQL_FILES, desc="Processing SQL files"):
            file_path = self._base_path / file_name

            if not file_path.exists():
                logger.error(f"File not found: {file_path}")
                raise
            
            # Calculate total lines
            total_lines = sum(1 for _ in open(file_path, 'r', encoding='utf-8'))
            logger.info(f'Total Lines: {total_lines}\tFile: {file_path}')
            # Read sql lines
            schema, table, columns, values = self.read_sql_file(file_name, 
                                                                     file_path,
                                                                      total_lines)
            if not values:
                logger.warning(f"No values found to insert into {file_name}")
                continue
            # create output file with the same name but in the bulk-load folder
            output_file = self._output_dir / f"{file_name[:-4]}_bulk_batches.sql"
            self._generate_bulk_insert(schema, table, columns, values, output_file)

def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Convert individual INSERTs to batched INSERTs with BEGIN/COMMIT."
    )
    parser.add_argument(
        "--batch-size", 
        type=int, 
        default=10000, 
        help="Batch size for INSERT statements (default: 10000)"
    )
    parser.add_argument(
        "--data-path", 
        type=str, 
        default="../../../data/sql", 
        help="path of data"
    )
    parser.add_argument(
        "--output-dir", 
        type=str, 
        default="bulk-load", 
        help="output directory name"
    )

    return parser.parse_args()


if __name__ == '__main__':
    args = parse_arguments()
    logger.info("Start process to convert SQL")
    obj = ConvertBulkInsert(args.batch_size, args.data_path, args.output_dir)
    obj.convert_to_bulk_insert()
    logger.info("SQL Pipeline completed successfully")
    