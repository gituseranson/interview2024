--dropping table for rerunning case, upset/truncate insert/delete insert should be used in real life cases
drop table landing_client_data.clients; 
drop table raw_client_data.clients;
drop table transformed_client_data.client_credentials;

CREATE TABLE IF NOT EXISTS landing_client_data.clients (
    id VARCHAR(255), 
    first_name VARCHAR(255) ,
    last_name VARCHAR(255) ,
    email VARCHAR(255) ,
    password VARCHAR(255) , -- may need to store securely
    created_on VARCHAR(255),
    unnamed VARCHAR(255) --assuming the income data always contain this column with issue, otherwise a data cleansing step is required before loading into db
);

CREATE TABLE IF NOT EXISTS raw_client_data.clients (
    id SERIAL PRIMARY KEY, 
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- may need to store securely
    created_on timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS transformed_client_data.client_credentials (
    client_id SERIAL PRIMARY KEY, 
    clientname VARCHAR(200) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- may need to store securely
    created_on TIMESTAMP NOT NULL,
    CONSTRAINT email_format CHECK (email ~* '^[^@][^@]*@[^@]+[^@]*$') -- Ensures email contains "@" in the correct position
);

-- Trigger to prevent altering the created_on field
CREATE OR REPLACE FUNCTION transformed_client_data.prevent_created_on_update() 
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.created_on <> NEW.created_on THEN
        RAISE EXCEPTION 'The created_on field cannot be updated.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger that applies the function on any update to the table
CREATE TRIGGER no_update_created_on
    BEFORE UPDATE ON transformed_client_data.client_credentials
    FOR EACH ROW
    EXECUTE FUNCTION transformed_client_data.prevent_created_on_update();

