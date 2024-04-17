//This will show the global history even if the table names were modified and reloaded

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY

//This will show for a specific table
SELECT * FROM COPY_DB.INFORMATION_SCHEMA.LOAD_HISTORY