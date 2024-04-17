// Creating a central DB to organize the stages
CREATE OR REPLACE DATABASE MANAGED_DB;
CREATE OR REPLACE SCHEMA external_stages;

//Creating an External Stage
CREATE OR REPLACE STAGE MANAGED_DB.EXTERNAL_STAGES.AWS_STAGE
    url = 's3://bucketsnowflakes3'
//To view the stage properties in command line
DESC STAGE aws_stage;

//To change any property of the stage

ALTER STAGE aws_stage
    SET credentials = (aws_key_id = 'XYZ_DUMMY_ID' aws_secret_key = '124abc');

//To list the contents of the stage
LIST @aws_stage;

//Creating a table called Orders and loading data from S3 bucket into this from OrderDetails.csv
CREATE OR REPLACE TABLE ORDERS (
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR
);

//View the blank table
SELECT * FROM ORDERS;

COPY INTO ORDERS
FROM @aws_stage
file_format = (type = csv field_delimiter = ',' skip_header= 1)
files = ('OrderDetails.csv');