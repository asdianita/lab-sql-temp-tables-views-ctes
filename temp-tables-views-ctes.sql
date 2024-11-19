USE sakila;

####### Creating a Customer Summary Report ######

## In this exercise, you will create a customer summary report that summarizes key information 
## about customers in the Sakila database, including their rental history and payment details. 
## The report will be generated using a combination of views, CTEs, and temporary tables.

## Step 1: Create a View
## First, create a view that summarizes rental information for each customer. The view should include 
## the customer's ID, name, email address, and total number of rentals (rental_count).
DROP VIEW rental_information_summary;
CREATE VIEW rental_information_summary AS
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       c.email,
       COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id # Left Join so customers with rental_count = 0 are taken into account.
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

SELECT * FROM rental_information_summary;

## Step 2: Create a Temporary Table
## Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
## The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
## and calculate the total amount paid by each customer.
DROP TEMPORARY TABLE total_amount_paid_by_customer;
CREATE TEMPORARY TABLE total_amount_paid_by_customer AS
SELECT ris.customer_id,
       SUM(p.amount) AS total_paid
FROM rental_information_summary ris
LEFT JOIN payment p ON ris.customer_id = p.customer_id
GROUP BY ris.customer_id;

SELECT * FROM total_amount_paid_by_customer;

## Step 3: Create a CTE and the Customer Summary Report
## Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
## The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH customer_summary_report AS (
    SELECT ris.customer_id,
       ris.first_name,
       ris.last_name,
       ris.email,
       ris.rental_count,
       tapbc.total_paid
    FROM rental_information_summary ris
    JOIN total_amount_paid_by_customer tapbc ON ris.customer_id = tapbc.customer_id
)
SELECT first_name, last_name, email, rental_count, total_paid
FROM customer_summary_report;

## Next, using the CTE, create the query to generate the final customer summary report, which should include: 
## customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived 
## column from total_paid and rental_count.

WITH customer_summary_report AS (
    SELECT ris.customer_id,
           ris.first_name,
           ris.last_name,
           ris.email,
           ris.rental_count,
           tapbc.total_paid
    FROM rental_information_summary ris
    JOIN total_amount_paid_by_customer tapbc ON ris.customer_id = tapbc.customer_id
)
SELECT 
    first_name,
    last_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count != 0 THEN total_paid / rental_count
        ELSE 0
    END AS average_payment_per_rental
FROM customer_summary_report;