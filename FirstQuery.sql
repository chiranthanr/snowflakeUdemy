CREATE WAREHOUSE SQL_Create
WITH 
WAREHOUSE_SIZE=XSMALL
MAX_CLUSTER_COUNT = 1
AUTO_SUSPEND = 300
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
COMMENT = 'This is a manually created WH from SQL'