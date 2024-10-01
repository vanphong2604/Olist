-- Query 1: Customer satisfaction
-- 	⁃	How many orders received a rating of 5 for each month in 2018 with the order status as 'delivered'? What percentage of orders with a rating of 5 accounted for the total number of orders in the corresponding month?
select 
	count(od.order_id) as total_orders, 
	extract(month from odr.review_create) as month
from order_reviews odr
join orders od on od.order_id = odr.order_id
where 
	od.order_status ='delivered' 
	and odr.review_score = '5'
	and extract(year from odr.review_create) =2018
group by month
-- Query 2: Customer payment trends when making purchases
-- 	⁃	How many orders were placed using each payment method, excluding orders with a 'canceled' status?
select 
	count(od.order_id) as total_orders, 
	op.payment_type
from orders od
join order_payments op on od.order_id = op.order_id 
where order_status != 'canceled'
group by payment_type
-- Query 3: Top-selling product trends 
-- 	⁃	Extract the top 10 products with the highest sales volume
Select 
	pt.category_translation, 
	sum(op.payment_value) as revenue 
from orders od 
join order_items oi on od.order_id = oi.order_id
join products pd on oi.product_id = pd.product_id
join product_translation pt on pd.product_category = pt.category
join order_payments op on op.order_id = oi.order_id
where order_status != 'canceled'
group by pt.category_translation
order by revenue desc
limit 10; 
-- 	⁃	Extract the 10 products with the lowest sales volume
Select 
	pt.category_translation, 
	sum(op.payment_value) as revenue 
from orders od 
join order_items oi on od.order_id = oi.order_id
join products pd on oi.product_id = pd.product_id
join product_translation pt on pd.product_category = pt.category
join order_payments op on op.order_id = oi.order_id
where order_status != 'canceled'
group by pt.category_translation
order by revenue asc
limit 10; 
-- Query 4: Olist's revenue
-- 	⁃	How has Olist's annual revenue changed over time?
Select 
	extract(year from order_purchase) as years,  
	sum(op.payment_value) as revenue 
from orders od
join order_payments op on od.order_id = op.order_id
group by years

-- Query 5: Order cancellations
-- 	⁃	What is the average cancellation rate, the number of canceled orders, the total revenue lost, and the number of affected sellers?
select 
    count(*) * 100.0 / (select count (*) from orders) as cancellation_rate,
	count(od.order_id) as cancelled_orders_count,
    sum(op.payment_value) as lost_revenue,
    count(distinct oi.seller_id) as affected_sellers 
from orders od
join order_payments op on od.order_id = op.order_id
join order_items oi on oi.order_id = od.order_id
join sellers s on oi.seller_id = s.seller_id
where od.order_status = 'canceled';

-- Query 6: Best-selling products
-- 	Which product is the best-selling each year and what is the total revenue generated?
with ranked_products as(
select 
	extract (year from od.order_purchase) as years,
	count(pd.product_id) as total,  
	product_category, 
	sum(op.payment_value) as revenue, 
	row_number() over (partition by extract(year from od.order_purchase) 
                           order by count(pd.product_id) desc) as rank
from orders od
join order_items oi on od.order_id = oi.order_id
join products pd on oi.product_id = pd.product_id
join order_payments op on oi.order_id = op.order_id
group by years, product_category
)
select 
    years, 
    product_category, 
    total, 
    revenue
from ranked_products
where rank = 1 
order by years;
-- Query 7: Purchase volume on Olist by region
-- 	⁃	Top 10 regions with the highest number of customers making purchases
select 
	count(od.order_id) as total_orders, cus.customer_state 
from orders od 
join customers cus on od.customer_id = cus.customer_id 
group by cus.customer_state 
order by total_orders desc
limit 10; 

--
select 
	count(distinct od.customer_id) as total_customers, cus.customer_state 
from orders od 
join customers cus on od.customer_id = cus.customer_id 
group by cus.customer_state 
order by total_customers desc
limit 10; 


-- Query 8: Customer review ratings
-- 	Extract products that have been reviewed by customers, the number of reviews, total revenue, and the average revenue per product based on rating

-- + 5: Excellent
-- + 4: Very good
-- + 3: Good
-- + 2: Bad
-- + 1: Very bad
select * from order_payments;
select * from orders;
select * from customers; 
select * from order_reviews; 