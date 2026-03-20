-- CREATE TABLES RELATED TO THE ORDERS AND PAYMENTS

-- ORDERS
CREATE TABLE pay.orders (
    id VARCHAR(25) PRIMARY KEY,
    customer_id_number VARCHAR(50) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) NULL,
    payment_method_id INT NOT NULL

);

-- ORDERS ITEMS
CREATE TABLE pay.order_items (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(25) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL
);


-- RELATIONSHIPS

ALTER TABLE pay.orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id_number) REFERENCES cs.customers(id_number);

ALTER TABLE pay.orders
ADD CONSTRAINT fk_payments_method
FOREIGN KEY (payment_method_id) REFERENCES ctg.payment_methods(id);

ALTER TABLE pay.order_items
ADD CONSTRAINT fk_order_orders
FOREIGN KEY (order_id) REFERENCES pay.orders(id);

ALTER TABLE pay.order_items
ADD CONSTRAINT fk_order_products
FOREIGN KEY (product_id) REFERENCES ctg.products(id);

-- CONSTRAINTS
ALTER TABLE pay.order_items
ADD CONSTRAINT chk_quantity CHECK (quantity > 0);