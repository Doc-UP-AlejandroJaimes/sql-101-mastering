-- Q1: COUNT ALL RECORDS
SELECT
  'cs.customers' AS user_table,
  COUNT(*) AS total_records
FROM cs.customers
UNION
SELECT
  'cs.orders' AS user_table,
  COUNT(*) AS total_records
FROM cs.orders
UNION
SELECT
  'cs.products' AS user_table,
  COUNT(*) AS total_records
FROM cs.products
UNION
SELECT
  'cs.order_items' AS user_table,
  COUNT(*) AS total_records
FROM cs.order_items

-- cs.customers	    85
-- cs.order_items	500
-- cs.orders	    250
-- cs.products	    25

-- Q2. GROUP BY AND COUNT BY DOMAINS

SELECT
    SPLIT_PART(email, '@', 2) AS domain,
    COUNT(*) AS total_records
FROM cs.customers
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- walmart.com	        2
-- desdev.cn	        2
-- bigcartel.com	    2
-- mlb.com	            2
-- timesonline.co.uk	2


-- Q3: PEOPLE OLDER THAN 50 AND OTHERWISE

-- CHECK AGE
SELECT
    id,
    AGE(CURRENT_DATE, birth_date) AS current_age
FROM cs.customers
LIMIT 5;

-- APPLY EXTRACT YEAR
WITH
people_age AS (
    SELECT
        id,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) AS years_old
    FROM cs.customers
)
SELECT
   COUNT(*) FILTER (WHERE years_old > 50) AS olders,
   COUNT(*) FILTER (WHERE years_old < 50) AS youngers
FROM people_age;


-- FUNCTION: USD_TO_COP

CREATE OR REPLACE FUNCTION convert_usd_to_cop()
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
    DECLARE
        rows_affected INT;
    BEGIN
        UPDATE cs.products
        SET cop_price = (usd_price * 3750);

        GET DIAGNOSTICS rows_affected = ROW_COUNT;

    RETURN 'Rows affected: '||rows_affected;   
END;
$$;

-- FUNCTION: UPDATE TOTAL
CREATE OR REPLACE FUNCTION update_total_orders()
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
    DECLARE
        rows_affected INT;
    BEGIN
        UPDATE cs.orders ord
        SET total = sub.total
        FROM (
            SELECT
                T1.order_id,
                SUM(T2.cop_price * T1.quantity) AS total
            FROM cs.order_items T1
            INNER JOIN cs.products T2
                ON T1.product_id = T2.id
            GROUP BY 1
        ) sub
        WHERE ord.id = sub.order_id;

        GET DIAGNOSTICS rows_affected = ROW_COUNT;

    RETURN 'Rows affected: '||rows_affected;   
END;
$$;

-- CHEK AND VALIDATE NULL ORDERS
SELECT COUNT(*) AS TOTAL_NULLS
FROM cs.orders WHERE total IS NULL;

SELECT id
FROM cs.orders WHERE total IS NULL
LIMIT 5;
-- 9

SELECT coalesce(total, 0) FROM cs.orders 
  WHERE id IN (9, 16, 17);

-- CHECK VALIDATION

SELECT *
FROM cs.orders T1
LEFT JOIN cs.order_items T2
  ON T1.id = T2.order_id
WHERE T1.id IN (9, 16, 17);










