USE COPY_DB.PUBLIC

SHOW TABLES

CREATE OR REPLACE TABLE ORDERS_SIZE(
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR
)

//Creating a new stage for the size exercise files
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.AWS_STAGE_SIZE
url = 's3://snowflakebucket-copyoption/size/'

LIST @AWS_STAGE_SIZE

COPY INTO ORDERS_SIZE
    FROM @AWS_STAGE_SIZE
    file_format = (type='csv' field_delimiter = ',' skip_header=1)
    pattern = '.*Order.*'
    SIZE_LIMIT = 60000;

SELECT * FROM ORDERS_SIZE