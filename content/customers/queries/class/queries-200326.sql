-- TOP 5: CUSTOMERS WITH MORE ORDERS

-- THE MOST YOUNGER CUSTOMER
SELECT
    name,
    id_number,
    phone_number,
    birth_date,
    EXTRACT (YEAR FROM AGE(CURRENT_DATE, birth_date)) AGE
FROM cs.customers T1
WHERE birth_date = 
(
    SELECT MAX(birth_date) FROM cs.customers
)
LIMIT 1;

-- THE MOST OLDER CUSTOMER


-- THE COMPANY WITH MORE SHIPS
SELECT
FROM 

-- TOTAL ORDERS COLLECTED BY CATEGORY
SELECT
        T3.name AS category,
        MONEY(SUM(T1.quantity * T2.cop_price)) AS total_by_category_cop,
        MONEY(SUM(T1.quantity * T2.usd_price)) AS total_by_category_usd
    FROM pay.order_items T1
    INNER JOIN ctg.products T2
        ON T1.product_id = T2.id
    INNER JOIN ctg.categories T3
        ON T2.category_id = T3.id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 5;