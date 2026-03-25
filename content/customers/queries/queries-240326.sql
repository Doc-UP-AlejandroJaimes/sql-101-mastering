-- Escriba una consulta que muestre, por cada orden de pay.orders, el
-- nombre del cliente (cs.customers), el order_id, la order_date y un
-- campo nro_orden que numere cronológicamente las órdenes de cada
-- cliente, comenzando en 1. Use PARTITION BY customer_id_number y
-- ORDER BY order_date ASC, id ASC como desempate.

SELECT
    T2.name AS customer,
    T1.customer_id_number,
    T1.id AS order_id,
    ROW_NUMBER() OVER (
        PARTITION BY T1.customer_id_number
        ORDER BY T1.order_date ASC,
                 T1.id ASC --desempate
    ) AS nro_orden
FROM pay.orders T1;
INNER JOIN cs.customers T2
    ON T1.customer_id_number = T2.id_number
GROUP BY T2.name, T1.customer_id_number;


-- A partir de la consulta anterior, envuélvala en una CTE y 
-- filtre únicamente las filas donde nro_orden = 1. 
-- El resultado debe contener exactamente una fila por cliente 
-- con su primera orden. Documente cuántos clientes 
-- tienen al menos una orden registrada.
-- [10012568, 10024615936, 1002749014]

WITH
orders_by_customer AS (
    SELECT
        T2.name AS customer,
        T1.customer_id_number,
        T1.id AS order_id,
        ROW_NUMBER() OVER (
            PARTITION BY T1.customer_id_number
            ORDER BY T1.order_date ASC,
                    T1.id ASC --desempate
        ) AS nro_orden
    FROM pay.orders T1
    INNER JOIN cs.customers T2
        ON T1.customer_id_number = T2.id_number
    GROUP BY T2.name, T1.customer_id_number, T1.id
)
SELECT * 
FROM orders_by_customer
WHERE customer_id_number 
    IN ('10012568','10024615936', '1002749014')
AND nro_orden = 1;

-- Escriba una consulta sobre ship.shipment_orders y ship.ship_company
-- que muestre: nombre de la empresa, total de órdenes despachadas,
-- rank_normal con RANK() y rank_dense con DENSE_RANK(), ambos
-- ordenados por total de envíos descendente.
WITH
orders_shipments_info AS (
    SELECT
        T1.ship_company_id,
        T2.name AS ship_company,
        COUNT(*) AS total_orders
    FROM ship.shipment_orders T1
    INNER JOIN ship.ship_company T2
        ON T1.ship_company_id = T2.id
    GROUP BY T1.ship_company_id, T2.name
)

SELECT
    ship_company,
    total_orders,
    SUM (total_orders) OVER() AS total_sum,
    RANK() OVER(
        ORDER BY total_orders DESC
    ) AS rank,
    DENSE_RANK() OVER(
        ORDER BY total_orders DESC
    ) AS dense_rank,
    ROW_NUMBER() OVER (
        ORDER BY total_orders DESC
    ) AS nro_shipment

FROM orders_shipments_info;