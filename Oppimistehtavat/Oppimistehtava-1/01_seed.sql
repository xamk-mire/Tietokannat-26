INSERT INTO categories (name) VALUES
('Tents'),
('Backpacks'),
('Sleeping Gear'),
('Hiking Accessories'),
('Outdoor Clothing');

SELECT * FROM categories;

-- Tents (category_id = 1)
INSERT INTO products (name, price, stock, category_id) VALUES
('Summit 2P Dome Tent', 149.99, 25, 1),
('TrailLite 1P Tent', 119.50, 12, 1),
('StormGuard 4P Family Tent', 279.00, 8, 1);

-- Backpacks (category_id = 2)
INSERT INTO products (name, price, stock, category_id) VALUES
('Ridgeway 30L Daypack', 79.95, 40, 2),
('Alpine Trek 55L Pack', 169.00, 18, 2),
('Waterproof Dry Bag 20L', 29.99, 60, 2);

-- Sleeping Gear (category_id = 3)
INSERT INTO products (name, price, stock, category_id) VALUES
('PolarLite Sleeping Bag -5C', 129.00, 20, 3),
('Summer Breeze Sleeping Bag +10C', 89.90, 35, 3),
('Ultralight Sleeping Pad', 49.50, 50, 3);

-- Hiking Accessories (category_id = 4)
INSERT INTO products (name, price, stock, category_id) VALUES
('TrekPro Hiking Poles (Pair)', 54.95, 30, 4),
('Headlamp 300 Lumens', 24.99, 70, 4),
('Stainless Steel Water Bottle 1L', 19.90, 90, 4);

-- Outdoor Clothing (category_id = 5)
INSERT INTO products (name, price, stock, category_id) VALUES
('Merino Wool Base Layer Top', 64.00, 45, 5),
('RainShell Waterproof Jacket', 119.00, 22, 5),
('Thermal Hiking Socks (2-Pack)', 14.99, 120, 5);