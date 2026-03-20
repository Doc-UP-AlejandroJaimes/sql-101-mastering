-- CREATE TABLES RELATED TO THE CATALOG

-- DEPARTMENTS
CREATE TABLE ctg.departments (
    code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
-- MUNICIPALITIES
CREATE TABLE ctg.municipalities (
    code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_code VARCHAR(10) NOT NULL
);
-- PRODUCTS
CREATE TABLE ctg.products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    usd_price DECIMAL(10, 2) NOT NULL,
    cop_price DECIMAL(10, 2) NULL,
    category_id INT NULL
);
-- CATEGORIES
CREATE TABLE ctg.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PAYMENT METHODS
CREATE TABLE ctg.payment_methods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RELATIONSHIPS
ALTER TABLE ctg.products
ADD CONSTRAINT fk_categories_id
FOREIGN KEY (category_id) REFERENCES ctg.categories(id);

ALTER TABLE ctg.municipalities
ADD CONSTRAINT fk_department_code
FOREIGN KEY (department_code) REFERENCES ctg.departments;