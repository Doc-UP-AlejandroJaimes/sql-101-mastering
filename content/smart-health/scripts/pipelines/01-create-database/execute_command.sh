# Primer Script
python .\01-create-database\01-sql-ddl-script-auto.py --sql-dir ../ddl --user postgres --password "pg.Up25**" --host localhost --port 5433 --database postgres --create-script true
# Segundo Script
python .\01-create-database\01-sql-ddl-script-auto.py --sql-dir ../ddl --user sm_admin --password "sm2025**" --host localhost --port 5433 --database smarthdb