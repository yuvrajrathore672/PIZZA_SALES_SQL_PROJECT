-- BASIC QUESTIONS

-- Q1) RETRIVE THE TOTAL NUMBER OF ORDERS PLACED.
SELECT COUNT(order_id) AS No_of_orders
FROM pizza_hut.orders;  

-- Q2) CALCULATE THE TOTAL REVENUE GENERATED FROM PIZZA SALES.

SELECT ROUND(SUM(order_detail.quantity * pizzas.price),2) AS total_revenue
FROM pizza_hut.order_detail
JOIN
pizza_hut.pizzas ON order_detail.pizza_id = pizzas.pizza_id;

-- Q3) IDENTIFY THE HIGHEST-PRICED PIZZA.

SELECT pizza_types.name, pizzas.price
FROM pizza_hut.pizza_types
JOIN pizza_hut.pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q4) IDENTIFY THE MOST COMMON PIZZA SIZE ORDERED.

SELECT pizzas.size,COUNT(order_detail.order_detail_id) AS order_count
FROM pizzas
JOIN order_detail ON pizzas.pizza_id = order_detail.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- Q5) LIST THE TOP 5 MOST ORDERED PIZZA TYPES ALONG WITH THEIR QUANTITIES.
 
SELECT pizza_types.name, SUM(order_detail.quantity) AS quanti
FROM pizza_hut.pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY quanti DESC
LIMIT 5;


-- INTERMEDIATE QUESTIONS

-- Q1) JOIN THE NECESSARY TABLES TO FIND THE TOTAL QUANTITY OF EACH PIZZA CATEGORY ORDERED.

SELECT pizza_types.category, SUM(order_detail.quantity)
FROM pizza_hut.pizza_types
JOIN pizza_hut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_detail ON pizzas.pizza_id = order_detail.pizza_id
GROUP BY category; 

-- Q2) DETERMINE THE DISTRIBUTION OF ORDERS BY HOUR OF THE DAY.

SELECT HOUR(order_time) AS hr, COUNT(order_id)
FROM orders
GROUP BY hr;

-- Q3) JOIN RELEVANT TABLES TO FIND CATEGORY-WISE DISTRIBUTION OF PIZZAS.

SELECT category, COUNT(name)
FROM pizza_hut.pizza_types
GROUP BY category;

-- Q4) GROUP THE ORDERS BY DATE AND CALCULATE AVERAGE NUMBER OF PIZZAS ORDER PER DAY.

SELECT AVG(quanty) AS average_order_perday
FROM
(SELECT orders.order_date AS date, 
SUM(order_detail.quantity) AS quanty
FROM orders
JOIN order_detail ON orders.order_id = order_detail.order_id
GROUP BY date) AS orders_by_date;


-- Q5) DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE.

SELECT pizza_types.name,ROUND(SUM(pizzas.price * order_detail.quantity),0) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;



-- ADVANCED QUESTION 

-- Q1) CALCULATE THE PERCENTAGE CONTRIBUTION OF EACH PIZZA TYPE TO TOTAL REVENUE

SELECT pizza_types.category,
ROUND(SUM(pizzas.price * order_detail.quantity) / (SELECT ROUND(SUM(pizzas.price * order_detail.quantity),2)
FROM order_detail 
JOIN pizzas ON pizzas.pizza_id = order_detail.pizza_id) * 100,2) AS contri
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY category;

-- Q2) Analyze the cumulative revenue generated over time.

select date, round(sum(revenue) over(order by date),0) as cum_revenue from 
(select orders.order_date as date , sum(pizzas.price* order_detail.quantity) as revenue
from order_detail
join orders on orders.order_id = order_detail.order_id
join pizzas on order_detail.pizza_id = pizzas.pizza_id
group by date) as sales;


-- Q3) DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE FOR EACH PIZZA CATEGORY.
 
select category,name,revenue 
from 
(select category,name,revenue ,rank()
over(partition by category order by revenue desc) as ranking
from 
(select pizza_types.category ,pizza_types.name ,round(sum(pizzas.price * order_detail.quantity),0) as revenue
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_detail on pizzas.pizza_id = order_detail.pizza_id
group by category ,name)as a) as b
where ranking<=3;


 