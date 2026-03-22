import unicodedata
import random as rand
from datetime import datetime, date
from typing import List
import pandas as pd
import numpy as np
import random
import uuid
import re


class HelperFunctions:

    @staticmethod
    def rename_cols(col: str) -> str:
        nfkd_form = unicodedata.normalize('NFKD', col)
        col_without_accents = nfkd_form.encode('ascii', 'ignore').decode('utf-8')
        return col_without_accents.replace('-', '_').replace(' ', '_').lower()

    @staticmethod
    def create_email(full_name: str) -> str:
        split_name = full_name.strip().split(' ')
        
        if len(split_name) > 1:
            first_part = f"{split_name[0].lower()}.{split_name[1].lower()}"
        else:
            first_part = f"{split_name[0].lower()}"

        domains = [
            'gmail.com', 'hotmail.com', 'yahoo.com', 'outlook.com',
            'popular.com', 'central.io', 'unipamplona.edu.co'
        ]

        rand_num = rand.randint(1, 50)
        domain = rand.choice(domains)

        if rand_num % 2 == 0:
            return f"{first_part}{rand_num}@{domain}"
        else:
            return f"{first_part}@{domain}"

    @staticmethod
    def generate_random_timestamps(size: int,
                                   start_date: str = '2025-01-01') -> pd.Series:
        current = datetime.now()

        start_date = pd.to_datetime(start_date)
        end_date = pd.to_datetime(current.strftime('%Y-%m-%d'))

        start_timestamp = start_date.timestamp()
        end_timestamp = end_date.timestamp()

        random_timestamps = np.random.uniform(
            start_timestamp,
            end_timestamp,
            size=size
        )

        return pd.to_datetime(random_timestamps, unit='s')
    @staticmethod
    def selected_cols(df:pd.DataFrame, cols:list) -> pd.DataFrame:
        return df[cols]
    
    @staticmethod
    def show_summary_by_key(df:pd.DataFrame, bussiness_key:str) -> None:
        summary = {
            "nulls": df[bussiness_key].isna().sum(),
            "duplicates": df.duplicated(subset=[bussiness_key]).sum(),
            "unique": df[bussiness_key].nunique()
        }
        print(summary)
    
    @staticmethod
    def drop_duplicates_by_key(df:pd.DataFrame, bussiness_key:str) -> pd.DataFrame:
        df = df[~df.duplicated(subset=[bussiness_key], keep=False)]
        return df
    
    @staticmethod
    def drop_nulls_by_key(df:pd.DataFrame, bussiness_key:str) -> pd.DataFrame:
        df = df.dropna(subset=[bussiness_key])
        return df
    
    @staticmethod
    def generate_fake_phone_col_number()->str:
        seed_header, seed_number = ('1203','1234567890')

        header = '3' + ''.join(rand.choices(seed_header, k = 2))
        first_part = ''.join(rand.choices(seed_number, k = 3))
        second_part = ''.join(rand.choices(seed_number, k = 4))
        check_random = rand.choice(seed_number)

        if int(check_random) % 2 != 0:
            second_part = second_part[:-1] + check_random

        return header + first_part + second_part
    
    @staticmethod
    def generate_dates_range(size:int,
                            start_date: str = '1970-01-01',
                            end_date: str = '2013-12-31',
                            ) -> pd.Series:
        
        # Define the start and end dates for the 'created_at' column
        start_date = pd.to_datetime(start_date)
        end_date = pd.to_datetime(end_date)

        # Convert dates to Unix timestamps
        start_timestamp = start_date.timestamp()
        end_timestamp = end_date.timestamp()

        # Generate a series of random Unix timestamps between the start and end
        random_timestamps = np.random.uniform(start_timestamp, end_timestamp, size=size)
        return pd.to_datetime(random_timestamps, unit='s')

    @staticmethod
    def format_value(val):
        if pd.isna(val):
            return 'NULL'
        if isinstance(val, (int, float, np.integer, np.floating)):
            return str(val)
        return f"'{str(val)}'"
    
    @staticmethod
    def generate_sql_statements (df:pd.DataFrame, schema:str, table_name:str) ->str:
        if schema is None:
            schema = 'public'
            print('Using public schema')
        else:
            columns = df.columns
            sql_statement = f"INSERT INTO {schema}.{table_name} ({', '.join(columns)}) VALUES "
            for _, row in df.iterrows():
                # format row 
                formatted_row = [HelperFunctions.format_value(row[col]) for col in columns]

                sql_statement += f"\n({', '.join(formatted_row)}),"
            sql_statement = sql_statement[:-1] + ';'


            return sql_statement
        
    @staticmethod
    def save_sql_statement(sql_statement: str, file_path: str):
        """
        Save SQL statement (string) to a file
        """
        with open(file_path, 'w') as f:
            f.write(sql_statement)

        print(f"SQL statement saved to {file_path}")
    
    @staticmethod
    def generate_order_id() -> str:
        """
        Format: ORDYYYYMMDD-XXXXXXX
        Sample: ORD20250315-X2A
        Longitude: 23 chars

        Returns:
            str: shipment_id
        """
        timestamp = datetime.now().strftime("%Y%m%d")
        unique    = uuid.uuid4().hex[:7].upper()
        return f"ORD{timestamp}-{unique}"
    
    @staticmethod
    def generate_order_items(order_ids: list[str],
                            min_items: int = 1,
                            max_items: int = 7,
                            min_product: int = 1,
                            max_product: int = 75,
                            min_qty: int = 1,
                            max_qty: int = 8) -> "pd.DataFrame":
        """
        Generate order items for a list of order IDs.

        Args:
            order_ids    : list of existing order IDs (VARCHAR 25)
            min_items    : minimum number of items per order
            max_items    : maximum number of items per order
            min_product  : minimum product_id
            max_product  : maximum product_id
            min_qty      : minimum quantity per item
            max_qty      : maximum quantity per item

        Returns:
            pd.DataFrame with columns: order_id, product_id, quantity
        """

        rows = []
        for order_id in order_ids:
            n_items  = random.randint(min_items, max_items)
            products = random.sample(range(min_product, max_product + 1), k=n_items)
            for product_id in products:
                rows.append({
                    "order_id"   : order_id,
                    "product_id" : product_id,
                    "quantity"   : random.randint(min_qty, max_qty),
                })

        return pd.DataFrame(rows, columns=["order_id", "product_id", "quantity"])

    @staticmethod
    def clean_razon_social(name:str) -> str:
        name = re.sub(r"[\'`]", "", name)
        return name.strip()
    
    @staticmethod
    def load_customers_id(sql_path: str) -> list[str]:
        pattern = re.compile(r"INSERT INTO cs\.customers[^;]+", re.DOTALL)
        row_pattern = re.compile(r"\(\s*'(\d+)'")
        
        with open(sql_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        match = pattern.search(content)
        if not match:
            return []
        
        return row_pattern.findall(match.group())
    
    @staticmethod
    def load_orders(sql_path: str) -> list[str]:
        pattern = re.compile(r"\(\s*'(ORD[^']+)'")
        with open(sql_path, "r", encoding="utf-8") as f:
            return pattern.findall(f.read())
    
    @staticmethod
    def drop_duplicates_from_list(dups: list, field:str, df: pd.DataFrame) -> pd.DataFrame:
        df_filtered = df[~df[field].astype(str).isin(dups)]
        print(f"Records originales : {len(df)}")
        print(f"Records deleted : {len(df) - len(df_filtered)}")
        print(f"Records remaining  : {len(df_filtered)}")
        return df_filtered
    
    @staticmethod
    def dedup_email(df: pd.DataFrame, email_col: str = 'email') -> pd.DataFrame:
        df = df.copy()
        mask = df.duplicated(subset=[email_col], keep='first')
        df.loc[mask, email_col] = df.loc[mask, email_col].apply(
            lambda x: x.replace('@', f'.{uuid.uuid4().hex[:4]}@')
        )
        return df
    
    @staticmethod
    def load_customers_email(sql_path: str) -> list[str]:
        pattern = re.compile(r"INSERT INTO cs\.customers[^;]+", re.DOTALL)
        row_pattern = re.compile(r"\(\s*'[^']+',\s*'[^']+',\s*'[^']+',\s*'[^']+',\s*'([^']+@[^']+)'")
        
        with open(sql_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        match = pattern.search(content)
        if not match:
            return []
        
        return row_pattern.findall(match.group())

    @staticmethod
    def dedup_email_from_list(existing_emails: list, df: pd.DataFrame, 
                            email_col: str = 'email') -> pd.DataFrame:
        df = df.copy()
        existing_set = set(existing_emails)
        
        mask = df[email_col].isin(existing_set)
        df.loc[mask, email_col] = df.loc[mask, email_col].apply(
            lambda x: x.replace('@', f'.{uuid.uuid4().hex[:4]}@')
        )
        
        print(f"Records originals  : {len(df)}")
        print(f"Records updateds : {mask.sum()}")
        
        return df


