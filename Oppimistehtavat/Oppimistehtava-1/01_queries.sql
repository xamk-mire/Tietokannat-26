-- All categories
SELECT * FROM categories;

-- All products
SELECT * FROM products;

-- Product names and prices
SELECT name, price FROM products;

-- Products with price over 50
SELECT * FROM products
WHERE price > 50;

-- Product names and prices sorted from most expensive to cheapest
SELECT name, price
FROM products
ORDER BY price DESC;