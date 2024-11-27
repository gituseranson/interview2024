#!/bin/bash
export PGPASSWORD='rbc2024'; #update here with the admin password
echo "Logging: Initalizing environment..."
psql -U postgres -f sql_script/init.sql

export PGPASSWORD='P@ssw0rd';
echo "Logging: Creating table..."
psql -U rbcuser -d clientdb -f sql_script/create_table.sql

echo "Logging: Inserting csv to table..."
psql -U rbcuser -d clientdb -f sql_script/insert_table.sql

echo "Logging: Cleaning and transforming table..."
psql -U rbcuser -d clientdb -f sql_script/cleaning_and_transformation.sql

echo "Logging: Running completed"
