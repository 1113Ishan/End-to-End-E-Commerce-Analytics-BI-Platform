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
	(revenue*1.0)/sum(revenue) over() as contribution,
	rank() over(order by revenue desc) as revenue_rank
from product_base;

/*
 * Analyzing the top performers:
 * Calculating cumulative contribution. 
 * products which fall under 
 * 80% <= cumulative_contribution = top performers,
 * 95% <= cumulative_contribution = mid performers,
 * everything below 95% are low performers.
 */

CREATE VIEW product_segmented_performance AS
SELECT 
    product_id,
    product_category_name,
    revenue,
    cumulative_contribution,
    CASE
        WHEN cumulative_contribution <= 0.80 THEN 'Top_performers'
        WHEN cumulative_contribution <= 0.95 THEN 'Mid_performers'
        ELSE 'Low_performers'
    END AS product_classification
FROM (
    SELECT 
        product_id,
        product_category_name,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC)
        / SUM(revenue) OVER () AS cumulative_contribution
    FROM product_performance
) t;

/*
 * Now, for category level analysis. 
 * Which category has the top performers.
 * Three segments:
 * 1. Hero category: high revenue, high orders
 * 2. Volume drivers category: low revenue, high orders
 * 3. Premium products: High revenue, low orders
 * 3. Week category: low revenue, low orders
 */


select 	
	product_category_name as category,
	count(*) as top_product_count,
	sum(revenue) as total_revenue
from product_segmented_performance
where product_classification = 'Top_performers'
group by product_category_name 
order by total_revenue desc;


/*
 * Grouping according to category's revenue contribution
*/


create view product_type_analysis as
with 
base as( 
		SELECT 
		    product_id,
		    product_category_name,
		    total_orders,
		    revenue,
		    revenue / NULLIF(total_orders, 0) AS revenue_per_order
		FROM product_performance
		),
stats as(
		select
			avg(total_orders) as avg_orders,
			avg(revenue) as avg_revenue
		from base
)
select b.*,
case
	when b.total_orders > s.avg_orders 
	and b.revenue > s.avg_revenue then 'Hero Category'	
	when b.total_orders > s.avg_orders 
	and b.revenue < s.avg_revenue then 'Volume Drivers'	
	when b.total_orders < s.avg_orders 
	and b.revenue > s.avg_revenue then 'Premium Category'
	else 'weak'
end as product_type
from base b
cross join stats s;

/*
 * products type analysis querry
 */

select count(*) from product_type_analysis
where product_type = 'Hero Category'

select count(*) from product_type_analysis
where product_type = 'Volume Drivers'

select count(*) from product_type_analysis
where product_type = 'Premium Category'


select count(*) from product_type_analysis;

select  count(*) from products_dataset;

/*
 * Now, analyzing active and inactive products
 * i.e products that are selling and products that are just sitting there in the inventory
 */

create view product_order_frequency as
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'Single Order Products'
        WHEN total_orders BETWEEN 2 AND 5 THEN 'Low Activity'
        WHEN total_orders > 5 THEN 'Active Products'
    END AS product_activity_segment,
    COUNT(*) AS product_count,
    SUM(revenue) AS total_revenue
FROM product_performance
GROUP BY 1
ORDER BY total_revenue DESC;



/*
 * Analysing customer pillar
 * 1. customer performance
 * 2. customer type filter (one time purchaser or repeated customer)
 */

create view customer_performance as
with order_level as (

	select 
		o.order_id,
		o.customer_id,
		sum(oi.price) as order_revenue,
		count(*) as items_in_order
	from orders_dataset o
	join order_items_dataset oi on oi.order_id = o.order_id 
	where o.order_status = 'delivered'
	group by o.order_id, o.customer_id 
)
select 
	customer_id,
	count(order_id) as total_orders,
	sum(order_revenue) as total_revenue,
	avg(order_revenue) as avg_order_value,
	sum(items_in_order) as total_items
from order_level
group by customer_id;


create view customer_segmentation as
select 
	customer_id, 
	total_orders,
	total_revenue,
	case
		when total_orders > 1 then 'Repeated_customer'
		else 'One_time_purchase'
	end as customer_type
from customer_performance;

SELECT 
    customer_id,
    total_revenue
FROM customer_performance
ORDER BY total_revenue DESC
LIMIT 10;

create view customer_spending_pattern as
	select 
	customer_id,
	total_revenue,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_revenue DESC) = 1 THEN 'Top Spenders'
        WHEN NTILE(4) OVER (ORDER BY total_revenue DESC) = 2 THEN 'High Spenders'
        WHEN NTILE(4) OVER (ORDER BY total_revenue DESC) = 3 THEN 'Mid Spenders'
        ELSE 'Low Spenders'
    END AS spend_segment
from customer_performance;

/*
 * Working on operation pillar
 * 1. delivery performance (delays, actual deliveries, estimated deliveries)
 */

CREATE VIEW delivery_performance AS
SELECT 
    order_id,
    customer_id,
    DATE_PART(
        'day', 
        NULLIF(order_delivered_customer_date, '')::timestamp 
        - order_purchase_timestamp::timestamp
    ) AS actual_delivery_days,
    DATE_PART(
        'day', 
        NULLIF(order_estimated_delivery_date, '')::timestamp 
        - order_purchase_timestamp::timestamp
    ) AS estimated_delivery_days,
    DATE_PART(
        'day', 
        NULLIF(order_delivered_customer_date, '')::timestamp 
        - NULLIF(order_estimated_delivery_date, '')::timestamp
    ) AS delay_days
FROM orders_dataset
WHERE order_status = 'delivered';

create view delivery_time as
select 
	case
		when delay_days < 0 then 'Early delivery'
		when delay_days = 0 then 'On time delivery'
		else 'Late delivery'
	end as delivery_status,
	count(*) as total_orders
from delivery_performance
group by 1
order by total_orders desc;


	
	
	


