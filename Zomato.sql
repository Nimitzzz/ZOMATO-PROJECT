CREATE DATABASE ZOMATO;
use ZOMATO;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES(1, '2017-09-22'),
(3, '2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid, signup_date) 
VALUES 
    (1, '2014-09-02'),
    (2, '2015-01-15'),
    (3, '2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid, created_date, product_id) 
VALUES 
    (1, '2017-04-19', 2),
    (3, '2019-12-18', 1),
    (2, '2020-07-20', 3),
    (1, '2019-10-23', 2),
    (1, '2018-03-19', 3),
    (3, '2016-12-20', 2),
    (1, '2016-11-09', 1),
    (1, '2016-05-20', 3),
    (2, '2017-09-24', 1),
    (1, '2017-03-11', 2),
    (1, '2016-03-11', 1),
    (3, '2016-11-10', 1),
    (3, '2017-12-07', 2),
    (3, '2016-12-15', 2),
    (2, '2017-11-08', 2),
    (2, '2018-09-10', 3);



drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

/*1 Total amount each customer spent on zomato? */

CREATE VIEW Expenses AS
SELECT 
    sales.userid, 
    SUM(product.price) AS total_expenses
FROM 
    sales
INNER JOIN 
    product 
ON 
    sales.product_id = product.product_id
GROUP BY 
    sales.userid;


/*2 How many days each customer visited zomato? */

CREATE VIEW Visits AS 
SELECT 
    userid,
    COUNT(DISTINCT created_date) AS visit_count
FROM 
    sales
GROUP BY 
    userid;
    
/*3 What was the first product bought by each customer? */

CREATE VIEW firstbuy AS
SELECT *
FROM (
    SELECT 
        sales.*,
        RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk
    FROM 
        sales
) AS ranked_sales
WHERE rnk = 1;

/*4 What is the most purchased item and how many times was it purchased by all customers? */

CREATE VIEW purchasecount AS
SELECT * 
FROM sales 
WHERE product_id = (
    SELECT product_id 
    FROM sales 
    GROUP BY product_id 
    ORDER BY COUNT(product_id) DESC 
    LIMIT 1
);
    
/*5 What item was the most popular for each customers? */

CREATE VIEW popular AS
SELECT 
    userid, 
    product_id, 
    product_count, 
    RANK() OVER (PARTITION BY userid ORDER BY product_count DESC) AS rnk
FROM (
    SELECT 
        userid, 
        product_id, 
        COUNT(product_id) AS product_count
    FROM 
        sales
    GROUP BY 
        userid, 
        product_id
) AS ranked_sales;

/*6 Which item was first purchased by customer after they became a member? */

CREATE VIEW goldpurchase AS
SELECT *
FROM (
    SELECT 
        c.*, 
        RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk
    FROM (
        SELECT 
            a.userid, 
            a.created_date, 
            a.product_id, 
            b.gold_signup_date
        FROM 
            sales a
        INNER JOIN 
            goldusers_signup b 
        ON 
            a.userid = b.userid 
        WHERE 
            a.created_date >= b.gold_signup_date
    ) c
) d
WHERE rnk = 1;

/*7 Which item was purchased by customer JUST BEFORE they became a member? */

CREATE VIEW beforegoldpurchase AS
SELECT *
FROM (
    SELECT 
        c.*, 
        RANK() OVER (PARTITION BY userid ORDER BY created_date desc) AS rnk
    FROM (
        SELECT 
            a.userid, 
            a.created_date, 
            a.product_id, 
            b.gold_signup_date
        FROM 
            sales a
        INNER JOIN 
            goldusers_signup b 
        ON 
            a.userid = b.userid 
        WHERE 
            a.created_date <= b.gold_signup_date
    ) c
) d
WHERE rnk = 1;


/* practice */

WITH RankedSales AS (
    SELECT 
        a.userid, 
        a.created_date, 
        a.product_id, 
        b.gold_signup_date,
        ROW_NUMBER() OVER (PARTITION BY a.userid ORDER BY a.created_date) AS rnk
    FROM 
        sales a
    INNER JOIN 
        goldusers_signup b ON a.userid = b.userid
    WHERE 
        a.created_date >= b.gold_signup_date
)
SELECT 
    userid, 
    created_date, 
    product_id, 
    gold_signup_date
FROM 
    RankedSales
WHERE 
    rnk = 1;


