USE OUR_FIRST_DB.PUBLIC

// Creating a Table with 2 columns which will be slectively imported from the AWS Stage

CREATE TABLE ORDER_EX2 (
    ORDER_ID VARCHAR,
    AMOUNT INT,OUR_FIRST_DB.PUBLIC.ORDER_EX2
    )
ALTER TABLE ORDER_EX2
RENAME COLUMN ORDEDR_ID TO ORDER_ID

//Selecting only two columns to copy into the new table
COPY INTO ORDER_EX2
    FROM (select s.$1,s.$2 from @MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE s )
    file_format = (type = csv field_delimiter = ',' skip_header=1)
    files = ('OrderDetails.csv');

SELECT * FROM ORDER_EX2

//Transformation while loading using CASE function

CREATE TABLE ORDER_EX3 (
    ORDEDR_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR
    )
COPY INTO ORDER_EX3
    FROM ( select 
            s.$1,
            s.$2,
            s.$3,
            CASE WHEN CAST (s.$3 as INT) >0 THEN 'Profitable' ELSE 'Non-Profitable' END
        from @MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE s
    )
    file_format = (type = 'csv' field_delimiter = ',' skip_header=1)
    files = ('OrderDetails.csv')

SELECT * FROM ORDER_EX3

//Transform data by extracting a substring into the new table EX4
CREATE TABLE ORDER_EX4 (
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    CATEGORY_SUBSTRING VARCHAR(5)
)

COPY INTO ORDER_EX4
FROM (select
        s.$1,
        s.$2,
        s.$3,
        substring(s.$5,1,5)
    from @MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE s)
    file_format = (type = 'csv' field_delimiter = ',' skip_header = 1)
    files = ('OrderDetails.csv')

SELECT * FROM ORDER_EX4
    
// Copy a subset of columns into the table i.e., the other columns will return empty into the new table
CREATE TABLE ORDER_EX5 (
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT
    )

COPY INTO ORDER_EX5 (ORDER_ID, PROFIT)
FROM (select
        s.$1,
        s.$3
        from @MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE s)
    file_format = (type = 'csv' field_delimiter = ',' skip_header=1)
    files = ('OrderDetails.csv')

SELECT * FROM ORDER_EX5

//Creating an autoincrementing column
CREATE OR REPLACE TABLE ORDER_EX6(
    ORDER_ID number autoincrement start 1 increment 1,
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR
)

COPY INTO ORDER_EX6 (AMOUNT,PROFIT)
FROM(select
        s.$2,
        s.$3
    from @MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE s)
    file_format = (type = 'csv' field_delimiter = ',' skip_header = 1)
    files = ('OrderDetails.csv')

SELECT * FROM ORDER_EX6