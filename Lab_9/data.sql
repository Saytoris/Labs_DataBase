-- Таблиці вимірів
CREATE TABLE products (id SERIAL PRIMARY KEY, product_name VARCHAR(100), category VARCHAR(50));
CREATE TABLE regions (id SERIAL PRIMARY KEY, region_name VARCHAR(50), country VARCHAR(50));
CREATE TABLE customers (id SERIAL PRIMARY KEY, customer_name VARCHAR(100), segment VARCHAR(50));

-- Таблиця фактів
CREATE TABLE sales (
    id SERIAL PRIMARY KEY, sale_date DATE, product_id INT, region_id INT, customer_id INT, quantity INT, revenue NUMERIC(10,2),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (region_id) REFERENCES regions(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Наповнення вимірів
INSERT INTO products (product_name, category) VALUES ('Laptop', 'Electronics'), ('Phone', 'Electronics'), ('Table', 'Furniture');
INSERT INTO regions (region_name, country) VALUES ('Kyiv', 'Ukraine'), ('Lviv', 'Ukraine'), ('Warsaw', 'Poland');
INSERT INTO customers (customer_name, segment) VALUES ('Company A', 'B2B'), ('Customer B', 'B2C');

-- Генерація 100 транзакцій фактів
INSERT INTO sales (sale_date, product_id, region_id, customer_id, quantity, revenue)
SELECT CURRENT_DATE - (random() * 365)::int, (random() * 2 + 1)::int, (random() * 2 + 1)::int, (random() * 1 + 1)::int, (random() * 10 + 1)::int, (random() * 5000 + 100)::numeric(10,2)
FROM generate_series(1, 100);

-- Створення агрегованого OLAP-представлення
CREATE VIEW orders_summary AS
SELECT DATE_PART('year', sale_date) AS year, DATE_PART('month', sale_date) AS month, p.category, r.region_name, SUM(s.revenue) AS revenue, SUM(s.quantity) AS quantity
FROM sales s JOIN products p ON s.product_id = p.id JOIN regions r ON s.region_id = r.id
GROUP BY year, month, p.category, r.region_name;