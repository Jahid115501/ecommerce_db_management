-- 1. Count total products per category
SELECT c.category_name, COUNT(p.product_id) AS product_count
FROM Category c
LEFT JOIN Product p ON c.category_id = p.category_id
GROUP BY c.category_id
ORDER BY product_count DESC;

-- 2. Top 5 best-selling products
SELECT p.product_name, SUM(od.quantity) AS total_sold
FROM Product p
JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC
LIMIT 5;

-- 3. Monthly sales trend analysis
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_price) AS monthly_sales,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(total_price)/COUNT(DISTINCT order_id) AS avg_order_value
FROM Order_Details
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 4. Customers who bought more than 5 items
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       SUM(od.quantity) AS total_items_purchased
FROM Customer c
JOIN Order_Details od ON c.customer_id = od.customer_id
GROUP BY c.customer_id
HAVING total_items_purchased > 5
ORDER BY total_items_purchased DESC;

-- 5. Find customers who ordered in last 30 days
SELECT DISTINCT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM Customer c
JOIN Order_Details od ON c.customer_id = od.customer_id
WHERE od.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);

-- 6. Total orders and revenue per customer
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(DISTINCT od.order_id) AS total_orders,
       SUM(od.total_price) AS total_spent
FROM Customer c
JOIN Order_Details od ON c.customer_id = od.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- 7. Average order value per customer
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       AVG(od.total_price) AS avg_order_value
FROM Customer c
JOIN Order_Details od ON c.customer_id = od.customer_id
GROUP BY c.customer_id
ORDER BY avg_order_value DESC;

-- 8. Top 5 customers by total spending
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       SUM(od.total_price) AS total_spent
FROM Customer c
JOIN Order_Details od ON c.customer_id = od.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;

-- 9. Products with stock less than 10
SELECT product_name, stock_quantity
FROM Product
WHERE stock_quantity < 10
ORDER BY stock_quantity ASC;

-- 10. Products that were never ordered
SELECT p.product_id, p.product_name
FROM Product p
LEFT JOIN Order_Details od ON p.product_id = od.product_id
WHERE od.product_id IS NULL;

-- 11. Stock analysis (identifying low stock products)
SELECT p.product_name, p.stock_quantity, 
       SUM(od.quantity) AS total_sold,
       (p.stock_quantity - IFNULL(SUM(od.quantity), 0)) AS remaining_stock
FROM Product p
LEFT JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY p.product_id
HAVING remaining_stock < 10;

-- 12. Category performance comparison
SELECT c.category_name, 
       SUM(od.total_price) AS total_sales,
       COUNT(DISTINCT od.order_id) AS order_count,
       AVG(p.price) AS avg_product_price
FROM Category c
JOIN Product p ON c.category_id = p.category_id
JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY c.category_id
ORDER BY total_sales DESC;

-- 13. Shipping performance analysis
SELECT status, 
       COUNT(*) AS shipment_count,
       AVG(DATEDIFF(delivery_date, shipping_date)) AS avg_delivery_days
FROM Shipping
GROUP BY status;

-- 14. Order fulfillment time analysis
SELECT o.order_id, 
       o.order_date,
       s.shipping_date,
       s.delivery_date,
       DATEDIFF(s.shipping_date, o.order_date) AS processing_time,
       DATEDIFF(s.delivery_date, s.shipping_date) AS shipping_time,
       DATEDIFF(s.delivery_date, o.order_date) AS total_fulfillment_time
FROM Order_Details o
JOIN Shipping s ON o.order_id = s.order_id
ORDER BY total_fulfillment_time DESC;

-- 15. Customer Lifetime Value (CLV) calculation
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       SUM(od.total_price) AS total_spent,
       COUNT(DISTINCT od.order_id) AS total_orders,
       SUM(od.total_price)/COUNT(DISTINCT od.order_id) AS avg_order_value
FROM Customer c
JOIN Order_Details od ON c.customer_id = od.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- 16. Orders that were shipped late
SELECT od.order_id, 
       DATEDIFF(s.delivery_date, s.shipping_date) AS delivery_days,
       s.status
FROM Order_Details od
JOIN Shipping s ON od.order_id = s.order_id
WHERE DATEDIFF(s.delivery_date, s.shipping_date) > 3
ORDER BY delivery_days DESC;

-- 17. Label orders as 'High' or 'Low' based on total_price > 500
SELECT order_id, total_price,
       CASE 
           WHEN total_price > 500 THEN 'High'
           ELSE 'Low'
       END AS order_value_label
FROM Order_Details
ORDER BY total_price DESC;

-- 18. Products with long description (> 200 chars)
SELECT product_name, CHAR_LENGTH(description) AS desc_length
FROM Product
WHERE CHAR_LENGTH(description) > 200
ORDER BY desc_length DESC;

-- 19. Most active day of week for orders
SELECT DAYNAME(order_date) AS day_of_week, 
       COUNT(order_id) AS order_count
FROM Order_Details
GROUP BY day_of_week
ORDER BY order_count DESC
LIMIT 1;

-- 20. Percentage of products out of stock
SELECT 
    (COUNT(CASE WHEN stock_quantity = 0 THEN 1 END) * 100.0 / COUNT(*)) AS out_of_stock_percentage
FROM Product;
