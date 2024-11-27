import psycopg2
import pandas as pd
from typing import Union, Optional


def connect_database(connection_dict: dict):
    """Connect to the PostgreSQL database server

    Args:
        connection_dict (dict): Dictionary contain connection credential.
                                e.g.{'dbname':"database1",'user':"user1",'password':"password",
                                    'host':"localhost", 'port':"5432"}
    Return:
        conn (psycopg2.connect): connect object created by psycopg2
    """
    conn = None
    try:
        print("Connecting to the database...")
        conn = psycopg2.connect(**connection_dict)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    print("Connected successfully")
    return conn


def read_data_from_client_table(
    conn: psycopg2.connect,
    id: Optional[Union[list, str, int]] = None,
    full_table_name: str = "transformed_client_data.client_credentials",
):
    """Reading data from a table in sql database (assuming always read the client table for ease of use)

    Args:
        conn (psycopg2.connect): connect object created by connect_database function
        id (Union[list,str,int]): the client id, it will retrieve  all the data from target table if id is None. Default is None.
        full_table_name (str): table schema and table name. Default is "transformed_client_data.client_credentials"

    Return:
        df (pd.DataFrame): dataframe read from database


    """
    if type(id) == list:
        id = ",".join(map(str, id))

    query = (
        f"select * from {full_table_name}"
        if id is None
        else f"select * from {full_table_name} where client_id in ({id})"
    )

    try:
        print(f"Reading Data from {full_table_name}...")
        df = pd.read_sql_query(query, conn)
        return df
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)


def alter_data_for_client_table(
    conn: psycopg2.connect,
    update_details_dict: dict,
    id: Optional[Union[list, str, int]] = None,
    full_table_name: str = "transformed_client_data.client_credentials",
):
    """Alter a table's data in sql database (assuming always read the client table for ease of use)

    Args:
        conn (psycopg2.connect): connect object created by connect_database function
        update_details_dict (dict): dictionary contain update info. Key is column to be updated, and value is the target value. e.g. {clientname : 'testing'}
        id (Union[list,str,int]): the client id, it will alter all the data from target table if id is None. Default is None.
        full_table_name (str): table schema and table name. Default is "transformed_client_data.client_credentials"

    Return:
        df (pd.DataFrame): dataframe contain record read from database after updates
    """
    if type(id) == list:
        id = ",".join(map(str, id))

    query = (
        f"select * from {full_table_name}"
        if id is None
        else f"select * from {full_table_name} where id in ({id})"
    )

    update_details = ",".join(
        map(str, [f"{key} = '{value}'" for key, value in update_details_dict.items()])
    )

    try:
        cursor = conn.cursor()
        query = (
            f"UPDATE {full_table_name} SET {update_details} where client_id in ({id})"
        )

        # printing out query for ease of debugging
        print(f"Query ran: {query}")
        cursor.execute(query)
        conn.commit()

        # Check if the update was successful
        if cursor.rowcount > 0:
            result = f"Client with ID {id} updated successfully!"
        else:
            result = f"No client found with ID {id}."

        # Close the cursor
        cursor.close()

        print(result)

        df=read_data_from_client_table(conn,id=id)
        return df

    except Exception as e:
        conn.rollback()
        print(f"Error: {e}")
        return "An error occurred while updating the client data."
