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

MISSING_ID_LIST = [71,82,41,125,119,224,230,202,9,45,183,213,210,134,220,137,176,57,154,115,114,234,102,231,17,135,204,106,185,64,124,16,123,98,166]

def generate_update_payment_methods() -> list:
    """
    Generate update payment methods
    
    Output
        - list of tuples with order id and payment method id
    """
    payments_methods = [1, 2, 3, 4, 5, 6, 7, 8]
    update_payment_methods = []
    
    # Update all orders
    # You can check with this query
    # SELECT COUNT(*) FROM cs.orders; 250
    
    for order_id in range(1, 251):
        payment_method_id = rand.choice(payments_methods)
        update_payment_method = {
            "order_id" : order_id,
            "payment_method_id" : payment_method_id
        }
        update_payment_methods.append(update_payment_method)
    
    return update_payment_methods


def generate_order_items() -> list:
    """
    Generate order items
    
    Output
        - list of tuples with order items
    """
    order_items = []
    
    for order_id in MISSING_ID_LIST:
        # Set the random quantity of items that populate this table
        items_products = rand.randint(1, 8)
        for _ in range(items_products): # Each order has n items
            product_id = rand.randint(26, 46)
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


def convert_list_to_sql_query_updated(
                            schema:str, 
                            table:str, 
                            values_updated_template:str,
                            data:list) -> list:
    """
    Update sql query with schema related
    
    Arguments:
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
        for order in data:
            # Set variables
            
            order_id = order['order_id']
            payment_method_id = order['payment_method_id']
            sql_query = f"UPDATE {schema}.{table}"
            sql_query += f"\n SET {values_updated_template.split(',')[1]} = {payment_method_id}\n" \
                            f"WHERE {values_updated_template.split(',')[0]} = {order_id};"
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
    filepath_oders_payments = os.path.join(script_path, '10-cs.update_orders.sql')
    
    # Call functions
    order_items = generate_order_items()
    products = generate_products()
    orders_payments = generate_update_payment_methods()
    
    # Make Statements
    sql_statements = {
        "products" : {
            "object" : products,
            "statement" : {
                "schema" : "cs",
                "table" : "products",
                "values" : "name, usd_price",
                "convert_function" : "convert_dict_to_sql_query"
            },
            "filepath" : filepath_products
        },
        "order_items" : {
            "object" : order_items,
            "statement" : {
                "schema" : "cs",
                "table" : "order_items",
                "values" : "order_id, product_id, quantity",
                "convert_function" : "convert_list_to_sql_query"
            },
            "filepath" : filepath_order_items
        },
        "orders_payments" : {
            "object" : orders_payments,
            "statement" : {
                "schema" : "cs",
                "table" : "orders",
                "values" : "id, payment_method_id",
                "convert_function" : "convert_list_to_sql_query_updated"
            },
            "filepath" : filepath_oders_payments
        }
    }
    
    functions_map = {
        "convert_dict_to_sql_query": convert_dict_to_sql_query,
        "convert_list_to_sql_query": convert_list_to_sql_query,
        "convert_list_to_sql_query_updated": convert_list_to_sql_query_updated
    }
    
    for key, value in sql_statements.items():
        # check object info
        obj = value['object']
        function_name = value['statement']['convert_function']
        
        # make body function
        func = functions_map[function_name]
        
        sql_statement = func(
            value["statement"]["schema"],
            value["statement"]["table"],
            value["statement"]["values"],
            obj
        )
        
        # Save to file
        save_sql_statement(
            sql_statement,
            value["filepath"]
        )