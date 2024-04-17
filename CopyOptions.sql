USE OUR_FIRST_DB.PUBLIC

// Validation Mode - Returning only the number of rows from copy instead of actually copying

CREATE DATABASE IF NOT EXISTS COPY_DB

CREATE OR REPLACE TABLE COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR,
    AMOUNT VARCHAR,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR
)

//Creating a stage object
CREATE STAGE COPY_DB.PUBLIC.aws_stage_copy
    url = 's3://snowflakebucket-copyoption/size/'

LIST @aws_stage_copy

//Copying into the table using VALIDATION_MODE and RETURN_ERRORS Options
COPY INTO ORDERS
FROM @MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
file_format = (type = csv field_delimiter = ',' skip_header = 1)
pattern = '.*Order.*'
VALIDATION_MODE = RETURN_ERRORS

//Copying into table using VALIDATION_MODE and RETURN_n_ROWS options
COPY INTO ORDERS
FROM @aws_stage_copy
file_format = (type='csv' field_delimiter = ',' skip_header = 1)
pattern = '.*Order.*'
VALIDATION_MODE = RETURN_100_ROWS

SELECT * FROM ORDERS

//Using the RETURN_N_ROWS option when there are errors in the source file (First 2 rows have error)
COPY INTO ORDERS
FROM @MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
file_format = (type = csv field_delimiter = ',' skip_header = 1)
pattern = '.*Orders.csv'
VALIDATION_MODE = RETURN_10_ROWS

//Loading more files with errors into new stage
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.aws_stage_copy2
    url = 's3://snowflakebucket-copyoption/returnfailed/'

LIST @aws_stage_copy2

//Using copy options with return errors from stage with errors in files
COPY INTO ORDERS
FROM @aws_stage_copy2
file_format = (type='csv' field_delimiter = ',' skip_header = 1)
pattern = '.*Order.*'
VALIDATION_MODE = RETURN_ERRORS

//Copy with only return_failed
COPY INTO ORDERS
FROM @aws_stage_copy2
file_format = (type='csv' field_delimiter = ',' skip_header = 1)
pattern = '.*Order.*'
ON_ERROR = 'CONTINUE'
RETURN_FAILED_ONLY = TRUE; //This will give a list of only the failed files in the load apart from what was already loaded from the continue option.

//Truncate columns option

CREATE OR REPLACE TABLE COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR,
    AMOUNT VARCHAR,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(5),
    SUBCATEGORY VARCHAR
)


COPY INTO ORDERS
FROM @aws_stage_copy2
file_format = (type='csv' field_delimiter = ',' skip_header = 1)
pattern = '.*Order.*'
ON_ERROR = 'CONTINUE'
TRUNCATECOLUMNS = TRUE; //This option will truncate the source columns to match target column and copy instead of throwing an error

//USING FORCE option to load a file into the table even if it was already loaded before thereby allowing duplication

COPY INTO ORDERS
FROM @aws_stage_copy2
file_format = (type='csv' field_delimiter = ',' skip_header = 1)
pattern = '.*Order.*'
ON_ERROR = 'CONTINUE'
TRUNCATECOLUMNS = TRUE
FORCE = TRUE;

SELECT * FROM ORDERS