-- Dimension: Date
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY, -- e.g., 19960704
    full_date DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INT NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL
);

-- Dimension: Customer
CREATE TABLE dim_customer (
    customer_sk SERIAL PRIMARY KEY, -- Surrogate key
    customer_id VARCHAR(5) NOT NULL, -- Natural key
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
    city VARCHAR(15),
    region VARCHAR(15),
    country VARCHAR(15)
);

-- Dimension: Product
CREATE TABLE dim_product (
    product_sk SERIAL PRIMARY KEY, -- Surrogate key
    product_id SMALLINT NOT NULL,  -- Natural key
    product_name VARCHAR(40) NOT NULL,
    category_name VARCHAR(15) NOT NULL,
    quantity_per_unit VARCHAR(20),
    is_discontinued BOOLEAN NOT NULL
);

-- Dimension: Employee
CREATE TABLE dim_employee (
    employee_sk SERIAL PRIMARY KEY, -- Surrogate key
    employee_id SMALLINT NOT NULL, -- Natural key
    employee_name VARCHAR(50) NOT NULL,
    title VARCHAR(30),
    city VARCHAR(15),
    country VARCHAR(15)
);

-- Fact: Sales
CREATE TABLE fact_sales (
    fact_id SERIAL PRIMARY KEY,
    date_key INT NOT NULL,
    customer_sk INT NOT NULL,
    product_sk INT NOT NULL,
    employee_sk INT NOT NULL,
    
    -- Measures
    quantity SMALLINT NOT NULL,
    unit_price REAL NOT NULL,
    discount REAL NOT NULL,
    sales_amount REAL NOT NULL,
    
    -- Foreign Keys
    CONSTRAINT fk_sales_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_sk) REFERENCES dim_product(product_sk),
    CONSTRAINT fk_sales_employee FOREIGN KEY (employee_sk) REFERENCES dim_employee(employee_sk)
);
