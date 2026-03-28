# Clean Execution | Customers DB

> Created: 14 March 2026

## Version History

| Author | Description | Date |
|---|---|---|
| Juan Alejandro Carrillo Jaimes | First version of document | 14 March 2026 |
| Juan Alejandro Carrillo Jaimes | Update with separate schema and real information | 20 March 2026 |
| Juan Alejandro Carrillo Jaimes | Additional data generated for customers, addresses, orders, order items and shipment orders | 22 March 2026 |
| Juan Alejandro Carrillo Jaimes | Additional data generated for orders, order items and shipment orders | 23 March 2026 |
| Juan Alejandro Carrillo Jaimes | Additional data generated for orders, order items and shipment orders. Additional Bulk Information Process | 28 March 2026 |

---

## Schema Architecture

The database is organized in five schemas, each with a clearly delimited responsibility.

| Schema | Responsibility |
|---|---|
| `ctg` | Catalogs: departments, municipalities, categories, payment methods |
| `cs` | Core: customers and addresses |
| `pay` | Payments: orders and order items with payment method reference |
| `ship` | Shipments: shipping companies and shipment orders |

---

## Execution Steps

### 1. Clean environment

Drop all existing objects before a fresh execution.

```sql
-- scripts/01-delete-objects.sql
-- Update object names if they differ from your local setup.
```

### 2. Create schemas

```sql
CREATE SCHEMA cs    AUTHORIZATION admin;
CREATE SCHEMA pay   AUTHORIZATION admin;
CREATE SCHEMA ship  AUTHORIZATION admin;
CREATE SCHEMA ctg   AUTHORIZATION admin;
```

### 3. Create tables

Execute DDL scripts in the following order to respect foreign key dependencies.

```
scripts/ddl/01-ddl-customers.sql
scripts/ddl/02-ddl-ctg.sql
scripts/ddl/03-ddl-cs.sql
scripts/ddl/04-ddl-pay.sql
scripts/ddl/05-ddl-ship.sql
```

Verify table creation:

```sql
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'cs'
ORDER BY tablename;
```

### 4. Create functions and triggers

Execute statements one by one to isolate any errors.

```
scripts/functions/ctg_functions.sql
scripts/functions/pay_functions.sql
scripts/triggers/ctg_triggers.sql
scripts/triggers/generic_triggers.sql
scripts/triggers/ship_triggers.sql
scripts/03-functions_and_triggers.sql
```

### 5. Insert data — initial load

#### Catalogs

```
data/sql/catalogs/01-INSERT-DEPARTMENTS.sql
data/sql/catalogs/02-INSERT-MUNICIPALITIES.sql
data/sql/catalogs/03-INSERT-CATEGORIES.sql
data/sql/catalogs/04-INSERT-PRODUCTS.sql
data/sql/catalogs/05-PAYMENT-METHODS.sql
```

#### Customers

```
data/sql/customers/customers_20260320.sql
data/sql/customers/addresses_20260320.sql
```

#### Orders

```
data/sql/payments/orders_20260320.sql
data/sql/payments/orders_items_20260320.sql
```

#### Shipments

```
data/sql/shipments/06-INSERT-SHIP-COMPANY.sql
data/sql/shipments/shipment_orders_20260320.sql
```

### 6. Execute price conversion

Converts all `usd_price` values to `cop_price` using a fixed exchange rate.

```sql
SELECT ctg.convert_usd_to_cop();
-- Expected: Rows affected: 46
```

### 7. Calculate order totals

Populates the `total` field in `pay.orders` based on order items and product prices.

```sql
SELECT pay.update_total_orders();
-- Expected: Rows affected: 250
```

### 8. Validate load

```sql
SELECT COUNT(*)
FROM pay.orders
WHERE total IS NULL;
-- Expected: 0
```

```sql
SELECT 'cs.addresses'          AS table_name, COUNT(*) AS total FROM cs.addresses
UNION ALL SELECT 'cs.customers',              COUNT(*) FROM cs.customers
UNION ALL SELECT 'ctg.categories',            COUNT(*) FROM ctg.categories
UNION ALL SELECT 'ctg.departments',           COUNT(*) FROM ctg.departments
UNION ALL SELECT 'ctg.municipalities',        COUNT(*) FROM ctg.municipalities
UNION ALL SELECT 'ctg.payment_methods',       COUNT(*) FROM ctg.payment_methods
UNION ALL SELECT 'ctg.products',              COUNT(*) FROM ctg.products
UNION ALL SELECT 'pay.order_items',           COUNT(*) FROM pay.order_items
UNION ALL SELECT 'pay.orders',                COUNT(*) FROM pay.orders
UNION ALL SELECT 'ship.shipment_orders',      COUNT(*) FROM ship.shipment_orders
UNION ALL SELECT 'ship.ship_company',         COUNT(*) FROM ship.ship_company;
```

---

## Incremental Loads

Incremental loads are delta files applied on top of the initial historical load. Execute them in order after the initial load is complete.

### Delta 20260322

Additional data generated for customers, addresses, orders, order items and shipment orders.

```
data/sql/customers/customers_20260322.sql
data/sql/customers/addresses_20260322.sql
data/sql/payments/orders_20260322.sql
data/sql/payments/orders_items_20260322.sql
data/sql/shipments/shipment_orders_20260322.sql
```

### Delta 20260323

Additional data generated for orders and shipment orders.

```
data/sql/payments/orders_variety_20260323.sql
data/sql/payments/orders_items_variety_20260323.sql
data/sql/payments/orders_update_20260323.sql
data/sql/shipments/shipment_orders_variety_20260323.sql
```

### Delta 20260328

Additional data generated for orders and shipment orders.

```
data/sql/customers/customers_20260328.sql
data/sql/customers/addresses_20260328.sql
data/sql/payments/orders_20260328.sql
data/sql/payments/orders_items_20260328.sql
data/sql/shipments/shipment_orders_20260328.sql
```

After each delta, re-run the totals function and validate:

```sql
SELECT pay.update_total_orders();

SELECT COUNT(*) FROM pay.orders WHERE total IS NULL;
-- Expected: 0
```

---

## Python Scripts

Data generation utilities used to populate the database with synthetic data.

| Script | Responsibility |
|---|---|
| `colombian_addr_generator.py` | Generates Colombian addresses with municipality codes |
| `generate_dummy_data.py` | Generates customers, orders and order items |
| `helper_functions.py` | Shared utilities: ID generation, deduplication, formatting |
| `shipment_generator.py` | Generates shipment orders with tracking codes |

---

## Notes

- The `cop_price` field in `ctg.products` is always populated via `ctg.convert_usd_to_cop()`, never manually.
- The `total` field in `pay.orders` is always populated via `pay.update_total_orders()` or the associated trigger, never manually.
- The `shipment_orders` table references `pay.orders` through `order_id`. The relationship is enforced by a `BEFORE INSERT` trigger that validates order existence and prevents duplicate shipment assignments.
- The `updated_at` field in `cs.addresses` and `ship.shipment_orders` is maintained automatically by the `trg_set_updated_at()` trigger.