# Clean Execution | Customers DB

> Created: 14 March 2026

## Version History

| Author                          | Description                                      | Date          |
|---------------------------------|--------------------------------------------------|---------------|
| Juan Alejandro Carrillo Jaimes  | First version of document                        | 14 March 2026 |
| Juan Alejandro Carrillo Jaimes  | Update with separate schema and real information | 20 March 2026 |

---

## Project Structure

```
customers/
├── data/
│   ├── raw/
│   └── sql/
│       ├── catalogs/
│       │   ├── 01-INSERT-DEPARTMENTS.sql
│       │   ├── 02-INSERT-MUNICIPALITIES.sql
│       │   ├── 03-INSERT-CATEGORIES.sql
│       │   ├── 04-INSERT-PRODUCTS.sql
│       │   └── 05-PAYMENT-METHODS.sql
│       ├── customers/
│       │   ├── addresses_20260320.sql
│       │   └── customers_20260320.sql
│       ├── payments/
│       │   ├── orders_20260320.sql
│       │   └── orders_items_20260320.sql
│       └── shipments/
│           ├── 06-INSERT-SHIP-COMPANY.sql
│           └── shipment_orders_20260320.sql
├── queries/
└── scripts/
    ├── ddl/
    │   ├── 01-ddl-customers.sql
    │   ├── 02-ddl-ctg.sql
    │   ├── 03-ddl-cs.sql
    │   ├── 04-ddl-pay.sql
    │   └── 05-ddl-ship.sql
    ├── functions/
    │   ├── ctg_functions.sql
    │   └── pay_functions.sql
    ├── python-scripts/
    │   ├── colombian_addr_generator.py
    │   ├── generate_dummy_data.py
    │   ├── helper_functions.py
    │   └── shipment_generator.py
    ├── triggers/
    │   ├── ctg_triggers.sql
    │   ├── generic_triggers.sql
    │   └── ship_triggers.sql
    ├── views/
    │   ├── 01-views.sql
    │   └── queries-100326.sql
    ├── 01-delete-objects.sql
    ├── 02-ddl-customers.sql
    └── 03-functions_and_triggers.sql
```

---

## Schema Architecture

The database is organized in five schemas, each with a clearly delimited responsibility.

Create the schemas with this script
```sql
-- CREATE SCHEMA
CREATE SCHEMA cs AUTHORIZATION admin;
CREATE SCHEMA pay AUTHORIZATION admin;
CREATE SCHEMA ship AUTHORIZATION admin;
CREATE SCHEMA ctg AUTHORIZATION admin;
```

| Schema      | Responsibility                                              |
|-------------|-------------------------------------------------------------|
| `ctg`       | Catalogs: departments, municipalities, categories, payment methods |
| `cs`        | Core: customers, addresses, products, orders, order items   |
| `pay`       | Payments: orders and order items with payment method reference |
| `ship`      | Shipments: shipping companies and shipment orders           |
| `customers` | Master database owner and entry point                       |

---

## Execution Steps

### 1. Clean environment

Drop all existing objects before a fresh execution.

```sql
-- scripts/01-delete-objects.sql
-- Update object names if they differ from your local setup.
```

### 2. Create schemas and tables

Execute DDL scripts in the following order to respect foreign key dependencies.

```sql
-- scripts/ddl/02-ddl-ctg.sql
-- scripts/ddl/03-ddl-cs.sql
-- scripts/ddl/04-ddl-pay.sql
-- scripts/ddl/05-ddl-ship.sql
```

Verify table creation:

```sql
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'cs'
ORDER BY tablename;
```

### 3. Create functions and triggers

Execute statements one by one to isolate any errors.

```sql
-- scripts/functions/ctg_functions.sql
-- scripts/functions/pay_functions.sql
-- scripts/triggers/ctg_triggers.sql
-- scripts/triggers/generic_triggers.sql
-- scripts/triggers/ship_triggers.sql
-- scripts/03-functions_and_triggers.sql
```

### 4. Insert data

#### Part 1 — Catalogs and core entities

```
data/sql/catalogs/01-INSERT-DEPARTMENTS.sql
data/sql/catalogs/02-INSERT-MUNICIPALITIES.sql
data/sql/catalogs/03-INSERT-CATEGORIES.sql
data/sql/catalogs/04-INSERT-PRODUCTS.sql
data/sql/catalogs/05-PAYMENT-METHODS.sql
data/sql/customers/customers_20260320.sql
data/sql/customers/addresses_20260320.sql
data/sql/payments/orders_20260320.sql
data/sql/payments/orders_items_20260320.sql
```

#### Part 2 — Shipments and updates

```
data/sql/shipments/06-INSERT-SHIP-COMPANY.sql
data/sql/shipments/shipment_orders_20260320.sql
```

### 5. Execute price conversion

Converts all `usd_price` values to `cop_price` using a fixed exchange rate.

```sql
SELECT cs.convert_usd_to_cop();
-- Expected: Rows affected: 46
```

### 6. Calculate order totals

Populates the `total` field in `cs.orders` based on order items and product prices.

```sql
SELECT cs.update_total_orders();
-- Expected: Rows affected: 250
```

### 7. Validate totals

```sql
SELECT COUNT(*)
FROM cs.orders
WHERE total IS NULL;
-- Expected: 0
```

---

## Python Scripts

Data generation utilities used to populate the database with synthetic data.

| Script                        | Responsibility                                              |
|-------------------------------|-------------------------------------------------------------|
| `colombian_addr_generator.py` | Generates Colombian addresses with municipality codes       |
| `generate_dummy_data.py`      | Generates customers, orders and order items                 |
| `helper_functions.py`         | Shared utilities: ID generation, deduplication, formatting  |
| `shipment_generator.py`       | Generates shipment orders with tracking codes               |

---

## Views

Reusable queries encapsulating common join logic across schemas.

```sql
-- scripts/views/01-views.sql
```

---

## Notes

- The `cop_price` field in `cs.products` is always populated via `cs.convert_usd_to_cop()`, never manually.
- The `total` field in `cs.orders` is always populated via `cs.update_total_orders()` or the associated trigger, never manually.
- The `shipment_orders` table references `pay.orders` through `order_id`. The relationship is enforced by a `BEFORE INSERT` trigger that validates order existence and prevents duplicate shipment assignments.
- The `updated_at` field in `cs.addresses` and `ship.shipment_orders` is maintained automatically by the `shared.trg_set_updated_at()` trigger.