-- DELETE TRIGGERS AND FUNCTIONS
DROP TRIGGER IF EXISTS tgg_update_price_cop_af_ins ON cs.products;
DROP FUNCTION IF EXISTS update_price_cop_af_ins();
DROP FUNCTION IF EXISTS update_category_id(INT, INT);
DROP FUNCTION IF EXISTS convert_usd_to_cop();

-- DELETE TABLES RELATED TO THE SCHEMA CS
DROP TABLE IF EXISTS cs.order_items;
DROP TABLE IF EXISTS cs.orders;
DROP TABLE IF EXISTS cs.products;
DROP TABLE IF EXISTS cs.categories;
DROP TABLE IF EXISTS cs.payment_methods;
DROP TABLE IF EXISTS cs.customers;

