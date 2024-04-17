USE MANAGED_DB
CREATE SCHEMA file_formats

CREATE file format MANAGED_DB.file_formats.my_file_format

DESC file format MANAGED_DB.file_formats.my_file_format

//Setting the file format object's values
ALTER file format MANAGED_DB.FILE_FORMATS.MY_FILE_FORMAT
SET SKIP_HEADER = 1

//Alternate is to specifiy the properties of the format object during creation
CREATE OR REPLACE file format MANAGED_DB.file_formats.my_file_format2
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1

//Copying data into a new table using file format object
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX10 (
    ORDER_COUNT number autoincrement start 1 increment 1,
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR
);

COPY INTO OUR_FIRST_DB.PUBLIC.ORDER_EX10 (ORDER_ID,AMOUNT,PROFIT,QUANTITY,CATEGORY,SUBCATEGORY)
FROM @aws_stage_errorex
file_format = (FORMAT_NAME = MANAGED_DB.FILE_FORMATS.MY_FILE_FORMAT2)
files = ('OrderDetails_error2.csv')
ON_ERROR = 'CONTINUE'

DROP TABLE OUR_FIRST_DB.PUBLIC.ORDER_EX10