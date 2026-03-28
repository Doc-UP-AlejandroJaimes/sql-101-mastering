-- CTE: Introduction Windows Functions
WITH
primera_compra AS (
    SELECT
        T1.id AS order_id,
        T1.customer_id_number,
        T1.order_date AS fecha_primer_compra,
        T1.total AS total_primera_compra
        
    FROM pay.orders T1
    INNER JOIN (
        SELECT MIN(id) AS primer_order_id, customer_id_number
        FROM pay.orders
        WHERE customer_id_number IN ('75099091', '30360752', '43715108')
        GROUP BY customer_id_number
    ) T2 
        ON T1.customer_id_number = T2.customer_id_number
        AND T1.id = T2.primer_order_id
),
gasto_por_cliente AS (
    SELECT
        customer_id_number,
        COUNT(*) AS total_orders,
        SUM(total) AS total_acumulado
    FROM pay.orders
    WHERE customer_id_number IN ('75099091', '30360752', '43715108')
    GROUP BY customer_id_number
),
comparacion_por_mes AS (
    SELECT
        actual.mes,
        actual.ventas_mes                                       AS ventas_actual,
        anterior.ventas_mes                                     AS ventas_anterior,
        actual.ventas_mes - COALESCE(anterior.ventas_mes, 0)   AS diferencia
    FROM (
        SELECT DATE_TRUNC('month', order_date) AS mes,
            SUM(total) AS ventas_mes
        FROM pay.orders 
        WHERE customer_id_number IN ('75099091', '30360752', '43715108') 
        AND total IS NOT NULL
        GROUP BY 1
    ) actual
    LEFT JOIN (
        SELECT DATE_TRUNC('month', order_date) AS mes,
            SUM(total) AS ventas_mes
        FROM pay.orders 
        WHERE customer_id_number IN ('75099091', '30360752', '43715108') 
        AND total IS NOT NULL
        GROUP BY 1
    ) anterior
        ON anterior.mes = actual.mes - INTERVAL '1 month'
    ORDER BY actual.mes
)

SELECT
		T1.id_number AS id_cliente,
    T1.name AS cliente,
    T2.fecha_primer_compra,
    T2.total_primera_compra,
    T3.total_acumulado,
    T3.total_orders,
    T4.ventas_actual,
    T4.ventas_anterior,
    T4.diferencia
FROM cs.customers T1
INNER JOIN primera_compra T2 ON T2.customer_id_number = T1.id_number
INNER JOIN gasto_por_cliente T3 ON T3.customer_id_number = T1.id_number
INNER JOIN comparacion_por_mes T4 ON
    DATE_TRUNC('month', T2.fecha_primer_compra) = T4.mes
ORDER BY T3.total_acumulado DESC;


-- TOTAL SHIPMENTS BY COMPANY
SELECT
    T1.name AS ship_company,
    COUNT(*) AS total_shipments,
    RANK()       OVER (
        ORDER BY COUNT(*) DESC
    )                             AS rank_normal,
    DENSE_RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS rank_dense

FROM ship.shipment_orders T1
INNER JOIN ship.ship_company T2
    ON T1.ship_company_id = T2.id
GROUP BY T1.name;

-- PERCENT FOR EACH COMPANY BY SHIPMENT
SELECT
    T2.name AS ship_company,
    COUNT(*) AS total_shipments,
    SUM(COUNT(*)) OVER () AS total_general,
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_total
FROM ship.shipment_orders T1
INNER JOIN ship.ship_company T2
    ON T1.ship_company_id = T2.id
GROUP BY T2.name
ORDER BY total_shipments DESC;



-----

 SELECT
        customer_id_number,
        COUNT(*) AS total_orders,
        SUM(total) AS total_acumulado,
        SUM(SUM(total)) OVER (
            ORDER BY DATE_TRUNC('month', order_date) ASC
        ) AS total_ventas_acumulado
FROM pay.orders
WHERE customer_id_number IN ('75099091', '30360752', '43715108')
GROUP BY customer_id_number



WITH ventas_mensuales AS (
    SELECT
        DATE_TRUNC('month', order_date)      AS mes,
        SUM(total)                           AS ventas_mes
    FROM pay.orders
    WHERE total IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    mes,
    ventas_mes,
    LAG(ventas_mes) OVER (
        ORDER BY mes ASC
    )                                        AS ventas_mes_anterior,
    ventas_mes - LAG(ventas_mes) OVER (
        ORDER BY mes ASC
    )                                        AS diferencia,
    ROUND(
        100.0 * (
            ventas_mes - LAG(ventas_mes) OVER (ORDER BY mes ASC)
        ) / LAG(ventas_mes) OVER (ORDER BY mes ASC),
        2
    )                                        AS pct_variacion
FROM ventas_mensuales
ORDER BY mes;



SELECT
    c.name                                   AS cliente,
    o.id                                     AS orden_id,
    o.order_date,
    LEAD(o.order_date) OVER (
        PARTITION BY o.customer_id_number
        ORDER BY     o.order_date ASC
    )                                        AS fecha_proxima_orden,
    LEAD(o.order_date) OVER (
        PARTITION BY o.customer_id_number
        ORDER BY     o.order_date ASC
    ) - o.order_date                         AS dias_hasta_proxima_orden
FROM pay.orders o
JOIN cs.customers c
    ON c.id_number = o.customer_id_number
ORDER BY c.name, o.order_date;

SELECT
    T2.name AS customer,
    T1.id AS order_id,
    T1.order_date,
    SUM (T1.total) OVER () (
        PARTITION BY T1.customer_id_number
        ORDER BY DATE_TRUNC('month', T1.order_date)
    ) AS acum_payments_by_customer,
    LEAD(T1.order_date) OVER (
        PARTITION BY T1.customer_id_number
        ORDER BY T1.order_date ASC
    ) AS date_next_order,

    LEAD(T1.order_date) OVER (
        PARTITION BY T1.customer_id_number
        ORDER BY T1.order_date ASC
    )  - T1.order_date AS days_until_next_order
FROM pay.orders T1
INNER JOIN cs.customers T2
    ON T2.id_number = T1.customer_id_number
WHERE T1.customer_id_number = '75099091'
ORDER BY T2.name, T1.order_date


-- ranking by city

WITH rankeados AS (
    SELECT
        mun.name                          AS municipio,
        c.name                            AS cliente,
        SUM(o.total)                      AS total_gastado,
        RANK() OVER (
            PARTITION BY a.municipality_code
            ORDER BY     SUM(o.total) DESC
        )                                 AS ranking
    FROM cs.customers        c
    JOIN cs.addresses        a   ON a.customer_id_number = c.id_number
    JOIN ctg.municipalities  mun ON mun.code             = a.municipality_code
    JOIN pay.orders          o   ON o.customer_id_number = c.id_number
    WHERE o.total IS NOT NULL
    GROUP BY a.municipality_code, mun.name, c.id_number, c.name
)
SELECT
    municipio,
    cliente,
    total_gastado,
    ranking
FROM   rankeados
WHERE  ranking <= 3
ORDER BY municipio, ranking;

-- segment customers
WITH gastos AS (
    SELECT
        o.customer_id_number,
        SUM(o.total)                      AS total_gastado,
        COUNT(DISTINCT o.id)              AS total_ordenes,
        MIN(o.order_date)                 AS primera_compra,
        MAX(o.order_date)                 AS ultima_compra,
        ROW_NUMBER() OVER (
            ORDER BY SUM(o.total) DESC
        )                                 AS ranking_global
    FROM pay.orders o
    WHERE o.total IS NOT NULL
    GROUP BY o.customer_id_number
)
SELECT
    c.name,
    c.email,
    g.primera_compra,
    g.ultima_compra,
    g.total_ordenes,
    g.total_gastado,
    g.ranking_global,
    CASE
        WHEN g.total_gastado  > 15000000 THEN 'VIP'
        WHEN g.total_gastado  >  7500000 THEN 'Regular'
        WHEN g.total_ordenes  >=   1 THEN 'Nuevo'
        ELSE                              'Sin compras'
    END                                   AS segmento
FROM gastos g
JOIN cs.customers c ON c.id_number = g.customer_id_number
ORDER BY g.total_gastado DESC;


WITH base AS (
    SELECT
        o.customer_id_number,
        o.id                                        AS order_id,
        o.order_date,
        o.total,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id_number
            ORDER BY     o.order_date ASC, o.id ASC
        )                                           AS nro_orden,
        SUM(o.total) OVER (
            PARTITION BY o.customer_id_number
        )                                           AS total_acumulado,
        COUNT(o.id) OVER (
            PARTITION BY o.customer_id_number
        )                                           AS total_orders
    FROM pay.orders o
    WHERE o.customer_id_number IN ('75099091', '30360752', '43715108')
      AND o.total IS NOT NULL
),
ventas_mensuales AS (
    SELECT
        DATE_TRUNC('month', order_date)             AS mes,
        SUM(total)                                  AS ventas_actual,
        LAG(SUM(total)) OVER (
            ORDER BY DATE_TRUNC('month', order_date) ASC
        )                                           AS ventas_anterior,
        SUM(total) - LAG(SUM(total)) OVER (
            ORDER BY DATE_TRUNC('month', order_date) ASC
        )                                           AS diferencia
    FROM pay.orders
    WHERE customer_id_number IN ('75099091', '30360752', '43715108')
      AND total IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    c.id_number                                     AS id_cliente,
    c.name                                          AS cliente,
    b.order_date                                    AS fecha_primera_compra,
    b.total                                         AS total_primera_compra,
    b.total_acumulado,
    b.total_orders,
    vm.ventas_actual,
    vm.ventas_anterior,
    vm.diferencia
FROM base b
JOIN cs.customers       c  ON c.id_number = b.customer_id_number
JOIN ventas_mensuales   vm ON vm.mes       = DATE_TRUNC('month', b.order_date)
WHERE b.nro_orden = 1
ORDER BY b.total_acumulado DESC;