CREATE VIEW monthly_revenue AS
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp::timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp::timestamp) AS month,
    SUM(oi.price) AS revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    SUM(oi.price) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS aov
FROM order_items_dataset oi
INNER JOIN orders_dataset o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;


CREATE VIEW category_revenue AS
WITH base AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp::timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp::timestamp) AS month,
        p.product_category_name AS category,
        SUM(oi.price) AS revenue,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(*) AS total_items_sold,
        SUM(oi.price) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS aov
    FROM order_items_dataset oi
    INNER JOIN orders_dataset o ON o.order_id = oi.order_id
    INNER JOIN products_dataset p ON p.product_id = oi.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY year, month, category
)
SELECT *,
    revenue / SUM(revenue) OVER (PARTITION BY year, month) AS revenue_contribution
FROM base
ORDER BY year, month, category;


create view product_performance as
with product_base as(
	select 
		p.product_id,
		p.product_category_name,
		count(distinct o.order_id) as total_orders,
		count(*) as total_items_sold, 
		sum(oi.price) as revenue
	from order_items_dataset oi
	inner join orders_dataset o on o.order_id = oi.order_id
	inner join products_dataset p on p.product_id = oi.product_id
	where o.order_status = 'delivered'
	group by p.product_id, p.product_category_name
)
select 
	product_id,
	product_category_name,
	total_orders,
	total_items_sold,
	revenue,
	sum(revenue) over() as total_revenue,
	(revenue*1.0)/sum(revenue) over() as contribution
from product_base;


