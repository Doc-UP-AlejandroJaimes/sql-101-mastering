-- CREATE TABLES RELATED TO THE CUSTOMERS

-- CUSTOMERS
CREATE TABLE cs.customers (
    id SERIAL PRIMARY KEY,
    id_number VARCHAR(50) UNIQUE NOT NULL,
    birth_date DATE NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ADDRESSES
CREATE TABLE cs.addresses (
    id SERIAL  PRIMARY KEY,
    customer_id_number VARCHAR(50) NOT NULL,
    municipality_code VARCHAR(10) NOT NULL,
    street VARCHAR(255) NOT NULL,
    detail VARCHAR(255) NULL,
    postal_code VARCHAR(20)  NULL,
    additional_comments VARCHAR(100) NULL,
    created_at TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP  DEFAULT CURRENT_TIMESTAMP
);


-- RELATIONSHIPS
ALTER TABLE cs.addresses
ADD CONSTRAINT fk_addr_customer
FOREIGN KEY (customer_id_number) REFERENCES cs.customers(id_number);


ALTER TABLE cs.addresses
ADD CONSTRAINT fk_addr_municipality
FOREIGN KEY (municipality_code) REFERENCES ctg.municipalities(code);

-- CONSTRAINTS
ALTER TABLE cs.customers
ADD CONSTRAINT chk_birth_date CHECK (birth_date < CURRENT_DATE);
