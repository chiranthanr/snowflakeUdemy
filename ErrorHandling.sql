USE MANAGED_DB.EXTERNAL_STAGES

CREATE OR REPLACE STAGE aws_stage_errorex
url = 's3://bucketsnowflakes4'

LIST @aws_stage_errorex

DESC STAGE aws_stage_errorex

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX7 (
    ORDER_COUNT number autoincrement start 1 increment 1,
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR    
)

//Default behaviour for ON_ERROR is the same as explicitly specifying ABORT_STATEMENT
COPY INTO OUR_FIRST_DB.PUBLIC.ORDER_EX7(ORDER_ID,AMOUNT,PROFIT,QUANTITY,CATEGORY,SUBCATEGORY)
FROM @aws_stage_errorex
file_format = (type = 'csv' field_delimiter = ',' skip_header = 1)
files = ('OrderDetails_error.csv')
ON_ERROR = 'ABORT_STATEMENT'

//Specitying 2 files, first with error and second without error
COPY INTO OUR_FIRST_DB.PUBLIC.ORDER_EX7(ORDER_ID,AMOUNT,PROFIT,QUANTITY,CATEGORY,SUBCATEGORY)
FROM @aws_stage_errorex
file_format = (type = 'csv' field_delimiter = ',' skip_header = 1)
files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
ON_ERROR = 'CONTINUE'

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDER_EX7
DROP TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX7

// Deleting all rows in the table (Note that TRUNCATE does not reset autoincrement column)
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX7

// Using 'SKIP_FILE' parameter for ON_ERROR
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX8(
    ORDER_COUNT number autoincrement start 1 increment 1,
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR
)

COPY INTO OUR_FIRST_DB.PUBLIC.ORDER_EX8(ORDER_ID,AMOUNT,PROFIT,QUANTITY,CATEGORY,SUBCATEGORY)
FROM @aws_stage_errorex
file_format = (type='csv' field_delimiter=',' skip_header=1)
files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
ON_ERROR = 'SKIP_FILE'

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDER_EX8

//SKIP_FILE parameter can be specified with error limits above which load will fail
 CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX9(
    ORDER_COUNT number autoincrement start 1 increment 1,
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR
 )

 COPY INTO OUR_FIRST_DB.PUBLIC.ORDER_EX9(ORDER_ID,AMOUNT,PROFIT,QUANTITY,CATEGORY,SUBCATEGORY)
 FROM @aws_stage_errorex
 file_format = (type = 'csv' field_delimiter = ',' skip_header = 1)
 files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
 //ON_ERROR = 'SKIP_FILE_10%' - first optin SKIP_FILE parameter with % of error threshold
 ON_ERROR = 'SKIP_FILE_1' //Option 2 - specifiing the max count of errors as threshold
 SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDER_EX9

 DROP TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX9