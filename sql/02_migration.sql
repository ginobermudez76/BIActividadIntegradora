-- Migrate dim_date
-- We extract unique order_date from orders
INSERT INTO dim_date (date_key, full_date, year, month, month_name, quarter, day_of_month, day_of_week, day_name)
SELECT DISTINCT
    CAST(TO_CHAR(order_date, 'YYYYMMDD') AS INT) AS date_key,
    order_date AS full_date,
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    TO_CHAR(order_date, 'Month') AS month_name,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(DAY FROM order_date) AS day_of_month,
    EXTRACT(DOW FROM order_date) AS day_of_week,
    TO_CHAR(order_date, 'Day') AS day_name
FROM orders
WHERE order_date IS NOT NULL
ON CONFLICT (date_key) DO NOTHING;

-- Migrate dim_customer
INSERT INTO dim_customer (customer_id, company_name, contact_name, city, region, country)
SELECT 
    customer_id, 
    company_name, 
    contact_name, 
    city, 
    region, 
    country
FROM customers;

-- Migrate dim_product
INSERT INTO dim_product (product_id, product_name, category_name, quantity_per_unit, is_discontinued)
SELECT 
    p.product_id, 
    p.product_name, 
    c.category_name, 
    p.quantity_per_unit, 
    CASE WHEN p.discontinued = 1 THEN TRUE ELSE FALSE END AS is_discontinued
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id;

-- Migrate dim_employee
INSERT INTO dim_employee (employee_id, employee_name, title, city, country)
SELECT 
    employee_id, 
    first_name || ' ' || last_name AS employee_name, 
    title, 
    city, 
    country
FROM employees;

-- Migrate fact_sales
INSERT INTO fact_sales (
    date_key, 
    customer_sk, 
    product_sk, 
    employee_sk, 
    quantity, 
    unit_price, 
    discount, 
    sales_amount
)
SELECT 
    CAST(TO_CHAR(o.order_date, 'YYYYMMDD') AS INT) AS date_key,
    dc.customer_sk,
    dp.product_sk,
    de.employee_sk,
    od.quantity,
    od.unit_price,
    od.discount,
    CAST(od.quantity * od.unit_price * (1 - od.discount) AS REAL) AS sales_amount
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN dim_customer dc ON o.customer_id = dc.customer_id
JOIN dim_product dp ON od.product_id = dp.product_id
JOIN dim_employee de ON o.employee_id = de.employee_id
WHERE o.order_date IS NOT NULL;
