CREATE DATABASE EXERCISE_DB;
CREATE SCHEMA PUBLIC;

USE EXERCISE_DB.PUBLIC;
CREATE TABLE CUSTOMERS(
    ID NUMBER,
    first_name VARCHAR,
    last_name VARCHAR,
    email VARCHAR,
    age NUMBER,
    CITY VARCHAR
)COMMENT = "Assignment 2 to load data from S3 bucket";

COPY INTO CUSTOMERS
FROM s3://snowflake-assignments-mc/gettingstarted/customers.csv
file_format = (type = csv
               field_delimiter = ","
               skip_header = 1
              );

//Displaying the rows
SELECT * FROM CUSTOMERS;