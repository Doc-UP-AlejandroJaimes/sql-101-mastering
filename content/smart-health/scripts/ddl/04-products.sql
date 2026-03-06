-- CREATE SCHEMA
CREATE SCHEMA IF NOT EXISTS pr AUTHORIZATION sm_admin;

-- CREATE TABLES

-- CATEGORIA
CREATE TABLE pr.categories(
    category_id SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

-- PRODUCTOS
CREATE TABLE pr.products(
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    category_id INTEGER NOT NULL
);

-- CLIENTES
CREATE TABLE pr.customers(
    id_card VARCHAR(20) PRIMARY KEY,
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(50) UNIQUE,
    phone_number VARCHAR(20) NOT NULL
);
-- ORDERS
CREATE TABLE pr.orders (
    order_id SERIAL PRIMARY KEY,
    id_card VARCHAR(20) NOT NULL,
    product_id INTEGER NOT NULL,
    q_products INTEGER NOT NULL,
    tax NUMERIC(1,2),
    subtotal NUMERIC(10,2),
    total NUMERIC(10,2),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--ALTER TABLES
-- CHECKS
ALTER TABLE pr.products
ADD CONSTRAINT chk_product_price
CHECK (price > 0);

ALTER TABLE pr.orders
ADD CONSTRAINT chk_q_products
CHECK (q_products > 0);
-- RELATIONSHIPS
--  1:1 categories - products
ALTER TABLE pr.products ADD CONSTRAINT fk_products_categories
    FOREIGN KEY (category_id) REFERENCES pr.categories (category_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;
-- 1:N products - orders
ALTER TABLE pr.orders ADD CONSTRAINT fk_orders_products
    FOREIGN KEY (product_id) REFERENCES pr.products (product_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- 1:N customers - orders
ALTER TABLE pr.orders ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (id_card) REFERENCES pr.customers (id_card)
    ON UPDATE CASCADE ON DELETE CASCADE;

--------------------
---- INSERT DATA----
--------------------
-- Insert data into Categories table
INSERT INTO pr.categories (description) VALUES
('Electronics'),
('Home Appliances'),
('Furniture'),
('Toys'),
('Clothing'),
('Sports'),
('Books'),
('Groceries'),
('Beauty'),
('Automotive');

-- Insert data into Products table
INSERT INTO pr.products (product_name, price, category_id) VALUES
('Smartphone', 299.99, 1),
('Laptop', 799.99, 1),
('Washing Machine', 450.00, 2),
('Sofa', 599.99, 3),
('Lego Set', 59.99, 4),
('T-shirt', 19.99, 5),
('Football', 29.99, 6),
('Novel', 15.99, 7),
('Shampoo', 9.99, 8),
('Car Battery', 120.00, 9);

-- Insert data into Customers table
INSERT INTO pr.customers (id_card, fullname, email, phone_number) VALUES
('ID1234567890', 'John Doe', 'john.doe@email.com', '555-1234'),
('ID9876543210', 'Jane Smith', 'jane.smith@email.com', '555-5678'),
('ID1112233445', 'Michael Johnson', 'michael.johnson@email.com', '555-8765'),
('ID5432109876', 'Emily Davis', 'emily.davis@email.com', '555-2345'),
('ID6789012345', 'Chris Lee', 'chris.lee@email.com', '555-9876'),
('ID3216549870', 'Jessica Brown', 'jessica.brown@email.com', '555-6543'),
('ID1122334455', 'David White', 'david.white@email.com', '555-3456'),
('ID2233445566', 'Sarah Williams', 'sarah.williams@email.com', '555-7654'),
('ID3344556677', 'Robert Miller', 'robert.miller@email.com', '555-8765'),
('ID4455667788', 'Linda Moore', 'linda.moore@email.com', '555-4321');

-- Insert data into Orders table
INSERT INTO pr.orders (id_card, product_id, q_products, tax, subtotal, total) VALUES
('ID1234567890', 1, 2, 0.15, 599.98, 689.97),
('ID9876543210', 2, 1, 0.10, 799.99, 879.99),
('ID1112233445', 3, 1, 0.12, 450.00, 504.00),
('ID5432109876', 4, 1, 0.08, 599.99, 647.99),
('ID6789012345', 5, 3, 0.05, 179.97, 188.97),
('ID3216549870', 6, 5, 0.18, 99.95, 117.94),
('ID1122334455', 7, 2, 0.10, 59.98, 69.98),
('ID2233445566', 8, 6, 0.08, 95.94, 103.42),
('ID3344556677', 9, 3, 0.05, 29.97, 31.47),
('ID4455667788', 10, 1, 0.10, 120.00, 132.00);

-------------------------------------------
--- CREATE FUNCTION TO TAX CALCULATIONS ---
-------------------------------------------

q_products <= 5 -> 0.19
q_products BETWEEN 6 AND 9 -> 0.15
q_products BETWEEN 10 AND 15 -> 0.1
q_products >= 16 -> 0.06

INSERT INTO pr.orders (id_card, product_id, q_products) VALUES
('ID1234567890', 1, 2);

--



CREATE OR REPLACE FUNCTION pr.tax_calculation(
    p_quant_product INTEGER
    )
    RETURNS NUMERIC(3,2)
    LANGUAGE plpgsql
AS 
$$
    DECLARE
        v_tax NUMERIC(3,2);
    BEGIN
        SELECT
    CASE 
        WHEN p_quant_product <= 5 THEN 0.19
        WHEN p_quant_product BETWEEN 6 AND 9 THEN 0.15
        WHEN p_quant_product BETWEEN 10 AND 15 THEN 0.1
    ELSE 0.06
    END TAX
    INTO v_tax;
    RETURN COALESCE(v_tax, 0);
    END;
$$;

SELECT pr.tax_calculation(5);