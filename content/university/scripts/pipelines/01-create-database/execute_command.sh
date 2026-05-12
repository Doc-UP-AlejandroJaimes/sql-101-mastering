# Primer Script
python .\01-create-database\01-sql-ddl-script-auto.py --sql-dir ../ddl --user postgres --password "*" --host localhost --port 5432 --database postgres --create-script true
# Segundo Script
python 01-sql-ddl-script-auto.py --sql-dir ../../ddl --user univ_admin --password '*' --host localhost --port 5432 --database universitydb