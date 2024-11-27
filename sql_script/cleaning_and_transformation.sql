insert into raw_client_data.clients 
select cast(id as integer),first_name,last_name,email,password, cast(created_on as timestamp) from landing_client_data.clients where id!='Goly' and unnamed is null;

insert into transformed_client_data.client_credentials 
select id as client_id,concat(first_name,', ',upper(last_name)) as clientname ,email,password,created_on from raw_client_data.clients ;
