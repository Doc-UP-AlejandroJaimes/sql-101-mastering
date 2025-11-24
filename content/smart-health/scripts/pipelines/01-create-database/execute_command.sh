# Primer Script
python .\01-create-database\01-sql-ddl-script-auto.py --sql-dir ../ddl --user postgres --password "Unipamplona2024**" --host localhost --port 5432 --database postgres --create-script true
# Segundo Script
python .\01-create-database\01-sql-ddl-script-auto.py --sql-dir ../ddl_parcial --user sm_admin --password "sm2025**" --host localhost --port 5433 --database smarthdb