-- function
smart_health.calcular_edad_paciente(20);

WITH tbl_paciente AS (
    SELECT
        patient_id,
        birth_date,
        smart_health.calcular_edad_paciente(20) AS edad_paciente
    FROM smart_health.patients
    WHERE patient_id = 20
)
SELECT
    edad_paciente,
    CASE 
        WHEN edad_paciente <= 18 THEN 'Joven'
        WHEN edad_paciente BETWEEN 19 AND 28 THEN 'Mejores anios'
        WHEN edad_paciente BETWEEN 29 AND 41 THEN 'Vivir la vida loca'
        ELSE 'Guardese sr'
    END desc_edad

 FROM tbl_paciente;

 ---------------
 --- TRIGGER ---

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

--- query final
WITH orders_products AS (
    SELECT
        T1.order_id,
        T1.product_id,
        T1.q_products as cantP,
        pr.tax_calculation(t1.q_products) as tax,
        (T1.q_products * T2.price) as subtotal
    FROM pr.orders T1
    INNER JOIN pr.products T2
        ON T1.product_id = T2.product_id
)
SELECT
    T1.product_id,
    T1.cantP,
    T1.tax,
    T1.subtotal,
    (T1.subtotal * (1 + T1.tax)) as total
FROM orders_products T1
INNER JOIN pr.orders T2
USING(order_id);

-- trigger_function

CREATE OR REPLACE FUNCTION pr.update_price_products()
RETURNS TRIGGER AS $$
DECLARE
    v_tax NUMERIC := 0;
    v_subtotal NUMERIC :=0;
    v_total NUMERIC :=0;
    v_price_product NUMERIC :=0;
BEGIN
    -- body function
    -- 01. query to pr.products for get price
    SELECT
        price
        INTO v_price_product
    FROM pr.products
    WHERE product_id = NEW.product_id;
    -- 02. calculate tax
    v_tax := pr.tax_calculation(NEW.q_products);
    -- 03. calculate subtotal
    v_subtotal := (NEW.q_products * v_price_product);
    -- 04. calculate total
    v_total := v_subtotal * (1 + v_tax);
    -- 05. update pr.orders with the new values
    UPDATE pr.orders
    SET tax = v_tax,
        subtotal = v_subtotal,
        total = v_total
    WHERE order_id = NEW.order_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- CREATE TRIGGER
CREATE OR REPLACE TRIGGER tgg_orders_auto
    AFTER INSERT OR UPDATE OF product_id, q_products
    ON pr.orders
    FOR EACH ROW
    EXECUTE FUNCTION pr.update_price_products();


INSERT INTO pr.orders (id_card, product_id, q_products) VALUES
('ID1234567890', 1, 2);

INSERT INTO pr.orders (id_card, product_id, q_products) VALUES
('ID9876543210', 2, 1);