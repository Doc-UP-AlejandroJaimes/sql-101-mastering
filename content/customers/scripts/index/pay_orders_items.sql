-- Primero se necesita un índice base
CREATE INDEX idx_orders_date
    ON pay.orders (order_date);

-- Luego se reordena físicamente la tabla
CLUSTER pay.orders USING idx_orders_date;

-- Las órdenes en disco quedan ordenadas por fecha
-- Las inserciones nuevas NO respetan ese orden
-- Hay que re-ejecutar CLUSTER periódicamenteS


-- Non-clustered por defecto — los datos no se reordenan
CREATE INDEX idx_orders_customer
    ON pay.orders (customer_id_number);

CREATE INDEX idx_items_product
    ON pay.order_items (product_id);

-- Ambos índices coexisten en la misma tabla
-- Cada uno apunta a las filas mediante ctid
-- Las filas en disco no cambian de posición

SELECT indexname
FROM pg_indexes
WHERE tablename = 'orders';


-- Ver estado actual de las páginas
SELECT ctid, id, order_date
FROM pay.orders
ORDER BY ctid
LIMIT 5;

-- Después de CLUSTER, los ctid se reorganizan
CLUSTER pay.orders USING idx_orders_date;

SELECT ctid, id, order_date
FROM pay.orders
ORDER BY ctid;

SELECT ctid, id, order_date, customer_id_number
FROM pay.orders
WHERE id IN
('ORD20260328-F3E5AE6', 
'ORD20260328-F18C067', 
'ORD20260328-7862229')
ORDER BY ctid;



SELECT id, 
order_date, 
customer_id_number
FROM pay.orders
WHERE id IN
('ORD20260328-F3E5AE6', 
'ORD20260328-F18C067', 
'ORD20260328-7862229');


SELECT id, order_date, customer_id_number
FROM pay.orders
WHERE id = 'ORD20260328-7862229';


CREATE EXTENSION pageinspect;
SELECT * FROM bt_metap('idx_orders_customer');



-- Default — no necesita USING btree, es implícito
CREATE INDEX idx_orders_customer
    ON pay.orders (customer_id_number);

-- Equivalente explícito
CREATE INDEX idx_orders_customer
    ON pay.orders USING btree (customer_id_number);

-- Funciona para igualdad
SELECT * FROM pay.orders
WHERE customer_id_number = '197803152182';

-- Funciona para rangos
SELECT * FROM pay.orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';

-- Funciona para ORDER BY
SELECT * FROM pay.orders
ORDER BY order_date DESC;

-- Ver altura del árbol
SELECT level FROM bt_metap('pay.idx_orders_customer');


-- Crear índice Hash sobre customer_id_number
CREATE INDEX idx_orders_customer_hash
    ON pay.orders USING hash (customer_id_number);

-- Solo funciona con igualdad exacta
SELECT * FROM pay.orders
WHERE customer_id_number = '197803152182';  -- usa el índice

-- Estos NO usan el índice hash
SELECT * FROM pay.orders
WHERE customer_id_number > '197803152182';  -- Seq Scan

SELECT * FROM pay.orders
ORDER BY customer_id_number;                -- Seq Scan


-- Supongamos que ctg.products tiene una columna de atributos JSONB
ALTER TABLE ctg.products
ADD COLUMN attributes JSONB NULL;

-- Índice GIN sobre la columna JSONB
CREATE INDEX idx_products_attributes
    ON ctg.products USING gin (attributes);

-- Buscar productos que tengan la clave 'color'
SELECT * FROM ctg.products
WHERE attributes ? 'color';

-- Buscar productos cuyo JSONB contenga ese par clave-valor
SELECT * FROM ctg.products
WHERE attributes @> '{"color": "negro"}';

-- GIN también sirve para búsqueda de texto completo
CREATE INDEX idx_products_name_fts
    ON ctg.products USING gin (to_tsvector('spanish', name));

SELECT * FROM ctg.products
WHERE to_tsvector('spanish', name) @@ to_tsquery('spanish', 'laptop');


-- BRIN sobre order_date — funciona porque las órdenes
-- se insertan cronológicamente y order_date crece con el tiempo
CREATE INDEX idx_orders_date_brin
    ON pay.orders USING brin (order_date);

-- Consulta por rango — BRIN descarta bloques completos
-- que están fuera del rango sin leerlos
SELECT * FROM pay.orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-06-30';

-- Ver cuántas páginas por rango usa el índice
SELECT * FROM brin_page_items(
    get_raw_page('pay.orders', 0),
    'idx_orders_date_brin'
);