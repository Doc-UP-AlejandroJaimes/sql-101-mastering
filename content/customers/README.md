# Clean Execution | Customers DB

## Last Updated
- 14 March 2026

## Steps
1. Delete all artifacts and objects created. Use the script `scripts/01-delete-objects.sql` if the name of the objects dont matching with yours scripts, please feel free to update this names for the correct objects that have been you created.
2. Create the tables with their constraints located in the ddl file. Use the script `scripts/02-ddl-customers.sql`
You can check with this query, that tables have been created.
   ```sql
   SELECT
      tablename
   FROM pg_catalog.pg_tables
   WHERE schemaname = 'cs'
   ORDER BY tablename
   ```
3. Create the functions and triggers, to the process located in the file `scripts/03-functions_and_triggers.sql`. I highly recommend execute statements one by one.
4. Insert data in this order.
   1. First part
      1. `data/01-cs.customers.sql`
      2. `data/02-cs.products.sql`
      3. `data/07-cs.categories.sql`
      4. `data/08-cs.payment_methods.sql`
      5. `data/03-cs.orders.sql`
      6. `data/04-cs.order_items.sql`
   2. Second part
      1. `data/05-cs.products2.sql`
      2. `data/06-cs.order_items2.sql`
      3. `data/09-updates-cs.products_categories.sql`
      4. `data/10-cs.update_orders.sql`

5. Execute the function to update usd to cop.

```sql
SELECT cs.convert_usd_to_cop();
-- Rows affected: 46
```
6. Execute the function to calculate total order.

```sql
SELECT cs.update_total_orders();
-- Rows affected: 250
```

7. Check that we dont have total values in null
```sql
SELECT
   COUNT(*)
FROM cs.orders
WHERE total IS NULL;
-- 0
```