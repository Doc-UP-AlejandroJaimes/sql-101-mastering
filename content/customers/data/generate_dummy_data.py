"""
generate_dummy_date.py

Developer: Juan Alejandro Carrillo Jaimes
Brief: This file generate sintetic data to populate the missing cases in orders
and order_items.
Created at: March 11 of 2026
"""

import os
import random as rand


''''
The missing data were obtained using the following query
 
SELECT
    id
FROM cs.orders
WHERE total IS NULL;
'''

MISSING_ID_LIST = [1,82,41,125,119,224,230,202,9,45,183,213,210,134,220,137,176,57,154,115,114,234,102,231,17,135,204,106,185,64,124,16,123,98,166]


def generate_order_items() -> list:
    """
    Generate order items
    
    Output
        - list of tuples with order items
    """
    order_items = []
    
    for order_id in MISSING_ID_LIST:
        # Set the random quantity of items that populate this table
        items_products = rand.randint(1, 6)
        for _ in range(items_products): # Each order has n items
            product_id = rand.randint(26, 45)
            quantity = rand.randint(1, 8)
            order_item = {
                "order_id" : order_id,
                "product_id" : product_id,
                "quantity" : quantity
            }
            order_items.append(order_item)
    
    return order_items

def generate_products() -> dict:
    """
    Generate products
    
    Output
        - dictionary with products names
    """
    products_names = {
        'Wireless Mouse' : 18.99,              
        'Mechanical Keyboard' : 79.5,
        'USB-C Charger' : 24.99,          
        'Laptop Standard' : 32,       
        'Bluetooth Speaker' : 45.75,            
        'External SSD 1TB' : 129.99,            
        'HD Webcam': 54.2,          
        'Noise Cancelling Headphones': 199, 
        'Gaming Mouse Pad': 14.95,            
        'Portable Monitor': 169.99,        
        'Smart LED Bulb': 12.49,            
        'USB Hub 6 -Port': 27.8,            
        'Ergonomic Chair Cushion': 36.4,     
        'Laptop Backpack': 49.99,             
        'Wireless Earbuds': 89,             
        'Tablet Stand': 21.6,             
        'HDMI Cable 2m': 9.75,               
        'Power Bank 20000mAh': 39.9,         
        'Desk Lamp LED': 28.3,            
        'Screen Cleaning Kit' : 11.2
    }
    return products_names    


def convert_dict_to_sql_query(schema:str, 
                            table:str, 
                            values_insert_template:str,
                            data:dict)-> list:
    """
    Convert dict to SQL query
    
    Arguments
        - schema:str schema of database
        - table:str table related to the insert
        - data:dict data in dictionary
    """
    results = []
    
    if schema is None:
        schema = 'public'
        print("No schema provided, using public schema")
    else:
        # Iterate and save
        sql_query = f"INSERT INTO {schema}.{table} ({values_insert_template}) VALUES "
        for name, price in data.items():
            sql_query += f"\n('{name}', {price}),"
        sql_query = sql_query[:-1] + ';' # Remove last comma and add semicolon
        results.append(sql_query)
    return results


def convert_list_to_sql_query(schema:str, 
                            table:str, 
                            values_insert_template:str,
                            data:list)-> list:
    """
    Convert list to SQL query
    
    Arguments
        - schema:str schema of database
        - table:str table related to the insert
        - data:list data of dictionaries
    """
    results = []
    
    if schema is None:
        schema = 'public'
        print("No schema provided, using public schema")
    else:
        # Iterate and save
        sql_query = f"INSERT INTO {schema}.{table} ({values_insert_template}) VALUES "
        for order_item in data:
            # Set variables
            order_id = order_item['order_id']
            product_id = order_item['product_id']
            quantity = order_item['quantity']       
            sql_query += f"\n({order_id}, {product_id}, {quantity}),"
        sql_query = sql_query[:-1] + ';' # Remove last comma and add semicolon
        results.append(sql_query)
    return results


def save_sql_statement(sql_statements:list, file_path:str):
    """
    Save SQL statements to a file
    
    Arguments
        - sql_statements:list list of SQL statements
        - file_path:str path to save the SQL statements
    """
    with open(file_path, 'w') as f:
        for statement in sql_statements:
            f.write(statement + '\n')
    print(f"SQL statements saved to {file_path}")
        
            

if __name__ == '__main__':
    
    # Set path
    script_path = os.path.dirname(os.path.abspath(__file__))
    
    filepath_products = os.path.join(script_path, '05-cs.products2.sql')
    filepath_order_items = os.path.join(script_path, '06-cs.order_items2.sql')
    files_path = [filepath_products, filepath_order_items]
    
    # Call functions
    order_items = generate_order_items()
    products = generate_products()
    objects = [products, order_items]
    
    # Generate SQL statements and save
    for index, object in enumerate(objects):
        sql_statement = None
        if isinstance(object, dict):
            # convert dict to sql
            sql_statement = convert_dict_to_sql_query(
                'cs',
                'products',
                'name, usd_price',
                object
            )
        else:
            sql_statement = convert_list_to_sql_query(
                'cs',
                'order_items',
                'order_id, product_id, quantity',
                object
            )
        # Save to file
        save_sql_statement(
            sql_statement,
            files_path[index]
        )