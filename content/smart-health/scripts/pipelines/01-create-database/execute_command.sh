# Primer Script
python .\01-create-database\01-sql-ddl-script-auto.py --sql-dir ../ddl --user postgres --password "****" --host localhost --port 5433 --database postgres --create-script true
# Segundo Script
python .\01-create-database\01-sql-ddl-script-auto.py --sql-dir ../ddl --user sm_admin --password "****" --host localhost --port 5433 --database smarthdb