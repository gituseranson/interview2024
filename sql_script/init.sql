--Creating Database and user
CREATE ROLE clientdb_user;
CREATE DATABASE clientdb;
CREATE USER rbcuser WITH PASSWORD 'P@ssw0rd';
Grant clientdb_user,pg_read_server_files TO rbcuser;

\connect clientdb

CREATE SCHEMA landing_client_data;
CREATE SCHEMA raw_client_data;
CREATE SCHEMA transformed_client_data;

--Granting necessary access to the role "clientdb_user"
GRANT CONNECT ON DATABASE clientdb TO clientdb_user;
GRANT CREATE,USAGE ON SCHEMA landing_client_data,raw_client_data,transformed_client_data TO clientdb_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA landing_client_data,raw_client_data,transformed_client_data  TO clientdb_user;
