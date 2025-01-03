use financial ;
CREATE TABLE goldusers_signups (userid integer, gold_signup_date date);
INSERT INTO goldusers_signups(userid, gold_signup_date) VALUES (1, STR_TO_DATE('09-22-2017', '%m-%d-%Y')), (3, STR_TO_DATE('04-21-2017', '%m-%d-%Y'));
select*from goldusers_signups

use financial ;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid, signup_date) VALUES (1, STR_TO_DATE('09-02-2014', '%m-%d-%Y')), (2, STR_TO_DATE('01-15-2015', '%m-%d-%Y')), (3, STR_TO_DATE('04-11-2014', '%m-%d-%Y'));
select * from users;

CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid, created_date, product_id) VALUES (1, STR_TO_DATE('04-19-2017', '%m-%d-%Y'), 2), (3, STR_TO_DATE('12-18-2019', '%m-%d-%Y'), 1), (2, STR_TO_DATE('07-20-2020', '%m-%d-%Y'), 3), (1, STR_TO_DATE('10-23-2019', '%m-%d-%Y'), 2), (1, STR_TO_DATE('03-19-2018', '%m-%d-%Y'), 3), (3, STR_TO_DATE('12-20-2016', '%m-%d-%Y'), 2), (1, STR_TO_DATE('11-09-2016', '%m-%d-%Y'), 1), (1, STR_TO_DATE('05-20-2016', '%m-%d-%Y'), 3), (2, STR_TO_DATE('09-24-2017', '%m-%d-%Y'), 1), (1, STR_TO_DATE('03-11-2017', '%m-%d-%Y'), 2), (1, STR_TO_DATE('03-11-2016', '%m-%d-%Y'), 1), (3, STR_TO_DATE('11-10-2016', '%m-%d-%Y'), 1), (3, STR_TO_DATE('12-07-2017', '%m-%d-%Y'), 2), (3, STR_TO_DATE('12-15-2016', '%m-%d-%Y'), 2), (2, STR_TO_DATE('11-08-2017', '%m-%d-%Y'), 2), (2, STR_TO_DATE('09-10-2018', '%m-%d-%Y'), 3);
select * from sales;

CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);
select * from sales;
select * from product;
select * from goldusers_signups;
select * from users;

1. What is the total amount each customer spent on Zomato?;
select a.userid,sum(b.price) total_amt_spent from sales a inner join product b on a.product_id=b.product_id
group by a.userid

2. how many each days has customer visited zomato?;
 select userid,count(distinct  created_date) distinct_days from sales group by userid;
 
 3. What was the first product purchased by each customer?;
 select*from
 (select * ,rank() over(partition by userid order by created_date ) rnk from sales) a where rnk =1;
 
 4. what is the most purchased item on the menu and how manyy times was it purchased by all customers?;
 select userid,count(product_id) cnt from sales where product_id =
 (select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid;

5. Which item was the most popular for each customer?;
select * from
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk =1;

6. Which item was purchased first by the customer after they beacame a member?;
select * from
(select c.*,rank() over(partition by userid order by created_date ) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signups_date from sales a inner join
goldusers_signups b on a.userid=c.userid and created_date>=gold_signups_date) c)d where rnk=1;

7. Which item was purchaseed before the customer became a member?;
SELECT * FROM ( 
SELECT c.*, RANK() OVER(PARTITION BY userid ORDER BY created_date) rnk 
FROM ( 
SELECT a.userid, a.created_date, a.product_id, b.signup_date 
FROM sales a 
INNER JOIN goldusers_signups b ON a.userid = b.userid AND a.created_date >= b.signup_date 
) c 
) d 
WHERE rnk = 1;
 
 8. What is the total order and amaount spent for each member before thet became a member?;
 select userid,count(created_date) order_purchased,sum(price) total_amt_spent from
 (select c.*,d.price from
 (select a.userid,a.created_date,a.product_id,b.gold_signups_date from sales a inner join
 goldusers_signups b on a.userid=b.userid and created_date<=gold_signups_date)c inner join product d on c.product_id=d.product_id)e
 group by userid;
 
 9. In the first one year after a customer joins the gold program (including their join date) irrespective
 of what the customer has purchased they earn zomato points for every 10 rs spent who earned more 1 or 3
and what was their points earnings in thier first yr?

1 zp-2rs
0.5 zp=1rs;

select c.*,d.price*0.5 total_points_earned from
(select a. userid,a.created_date,a. product_id,b.gold_signups_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date>gold_signups_date and created_date<=dateadd(year, 1,gold_signups_date))c
inner join product d on c.product_id=d.product_id; 

10. rnk all the transaction of the customers?;
select *, rank() over(partition by userid order by created_date ) rnk from sales;