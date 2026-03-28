-- CREATE TRIGGER THAT AFTER INSERT
-- UPDATE AUTO THE COP PRICE
CREATE OR REPLACE FUNCTION update_price_cop_af_ins()
RETURNS TRIGGER
LANGUAGE plpgsql
AS 
$$
    BEGIN

    UPDATE cs.products
    SET cop_price = (usd_price * 3750)
    WHERE id = NEW.id;

    RETURN NEW;

END;
$$;

CREATE TRIGGER tgg_update_price_cop_af_ins
AFTER INSERT ON cs.products
FOR EACH ROW
EXECUTE FUNCTION update_price_cop_af_ins();



SELECT
    *
FROM cs.products;

-- CREATE TABLES
CREATE TABLE cs.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

CREATE TABLE cs.payment_methods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- ADD COLUMN IN RELATED TABLES
-- AND ADD FOREIGN KEY

ALTER TABLE cs.products
ADD COLUMN category_id INT,
ADD CONSTRAINT fk_categories_id
FOREIGN KEY (category_id)
REFERENCES cs.categories(id);


ALTER TABLE cs.orders
ADD COLUMN payment_method_id INT,
ADD CONSTRAINT fk_payment_method_id
FOREIGN KEY (payment_method_id)
REFERENCES cs.payment_methods(id);


-- FUNCTION TO UPDATE THE CATEGORIES IN PRODUCTS
CREATE OR REPLACE FUNCTION update_category_id(product_id INT,
                                             cat_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
    DECLARE
        rows_affected INTEGER;
    BEGIN
        UPDATE cs.products
        SET category_id = cat_id
        WHERE id = product_id;

        GET DIAGNOSTICS rows_affected = ROW_COUNT;

        RETURN 'Rows affected: '|| rows_affected;
    END;
$$;