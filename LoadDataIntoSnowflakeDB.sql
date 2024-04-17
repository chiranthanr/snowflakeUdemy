ALTER DATABASE FIRST_DB RENAME TO OUR_FIRST_DB;
// Creating a table called LOAN_PAYMENT in the schema called PUBLIC
CREATE TABLE OUR_FIRST_DB.PUBLIC.LOAN_PAYMENT (
    "Loan_ID" STRING,
    "Loan_status" STRING,
    "Principal" STRING,
    "Terms" STRING,
    "effective_date" STRING,
    "due_date" STRING,
    "paid_off_time" STRING,
    "past_due_days" STRING,
    "age" STRING,
    "education" STRING,
    "Gender" STRING
);

USE OUR_FIRST_DB.PUBLIC;

// Checking whether the table exists
SELECT * FROM LOAN_PAYMENT

//Copying Data from S3 bucket into the table
COPY INTO LOAN_PAYMENT
FROM S3://bucketsnowflakes3/Loan_payments_data.csv
file_format = (type = csv
               field_delimiter = ","
               skip_header = 1);

//Viewing the loaded data
SELECT * FROM LOAN_PAYMENT;