-- Seed test data: 5-10 rows per table for testing.
-- Run after migrations V001..V012 and triggers. Uses created_by=0 (SYSTEM) where allowed.
-- Prerequisite: user_id=0 (SYSTEM) exists (from V002).
-- Order: run this first; then run scripts/run_business_flow.sql to exercise procedures.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- Users (user_id 0 = SYSTEM already in V002; add 2 test users).
-- ON DUPLICATE KEY so user_id=1,2 always exist for addresses and other refs.
-- ---------------------------------------------------------------------------
INSERT INTO user (user_id, username, email, password_hash, first_name, last_name, user_status_id, created_by,
                  modified_by)
VALUES (1, 'customer1', 'customer1@test.com', '$2a$10$dummy', 'Anna', 'Kovalenko', 1, 0, 0),
       (2, 'admin1', 'admin@test.com', '$2a$10$dummy', 'Admin', 'User', 1, 0, 0)
ON DUPLICATE KEY UPDATE username       = VALUES(username),
                        email          = VALUES(email),
                        password_hash  = VALUES(password_hash),
                        first_name     = VALUES(first_name),
                        last_name      = VALUES(last_name),
                        user_status_id = VALUES(user_status_id),
                        modified_by    = VALUES(modified_by);

-- ---------------------------------------------------------------------------
-- Addresses (for user 1; 5 rows). ON DUPLICATE KEY so re-run updates instead of skipping.
-- Prerequisite: user_id=1 must exist (inserted above).
-- ---------------------------------------------------------------------------
INSERT INTO address (address_id, user_id, street, city, postal_code, country, is_default, created_by, modified_by)
VALUES (1, 1, 'Khreshchatyk 1', 'Kyiv', '01001', 'Ukraine', 1, 0, 0),
       (2, 1, 'Bandery 10', 'Lviv', '79000', 'Ukraine', 0, 0, 0),
       (3, 1, 'Soborna 5', 'Odesa', '65000', 'Ukraine', 0, 0, 0),
       (4, 1, 'Pushkinska 22', 'Kharkiv', '61000', 'Ukraine', 0, 0, 0),
       (5, 1, 'Dnipro 7', 'Dnipro', '49000', 'Ukraine', 0, 0, 0)
ON DUPLICATE KEY UPDATE user_id     = VALUES(user_id),
                        street      = VALUES(street),
                        city        = VALUES(city),
                        postal_code = VALUES(postal_code),
                        country     = VALUES(country),
                        is_default  = VALUES(is_default),
                        modified_by = VALUES(modified_by);

-- ---------------------------------------------------------------------------
-- Categories (5)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO category (category_id, name, slug, description, created_by, modified_by)
VALUES (1, 'Electronics', 'electronics', 'Phones, laptops, gadgets', 0, 0),
       (2, 'Home', 'home', 'Home and kitchen', 0, 0),
       (3, 'Clothing', 'clothing', 'Apparel', 0, 0),
       (4, 'Sports', 'sports', 'Sports and outdoor', 0, 0),
       (5, 'Books', 'books', 'Books and media', 0, 0);

-- ---------------------------------------------------------------------------
-- Sub-categories (8; parent_id -> category)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO sub_category (sub_category_id, parent_id, name, slug, created_by, modified_by)
VALUES (1, 1, 'Smartphones', 'smartphones', 0, 0),
       (2, 1, 'Laptops', 'laptops', 0, 0),
       (3, 1, 'Accessories', 'accessories', 0, 0),
       (4, 2, 'Small appliances', 'small-appliances', 0, 0),
       (5, 2, 'Furniture', 'furniture', 0, 0),
       (6, 3, 'T-Shirts', 't-shirts', 0, 0),
       (7, 4, 'Fitness', 'fitness', 0, 0),
       (8, 5, 'Fiction', 'fiction', 0, 0);

-- ---------------------------------------------------------------------------
-- Brands (5)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO brand (brand_id, name, slug, description, created_by, modified_by)
VALUES (1, 'TechBrand', 'techbrand', 'Tech devices', 0, 0),
       (2, 'HomePro', 'homepro', 'Home appliances', 0, 0),
       (3, 'SportLine', 'sportline', 'Sports gear', 0, 0),
       (4, 'FashionCo', 'fashionco', 'Clothing', 0, 0),
       (5, 'BookWorld', 'bookworld', 'Publishing', 0, 0);

-- ---------------------------------------------------------------------------
-- Product attributes (size, color; 10 rows)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO product_attribute (product_attribute_id, attribute_type, attribute_value, created_by, modified_by)
VALUES (1, 'size', 'S', 0, 0),
       (2, 'size', 'M', 0, 0),
       (3, 'size', 'L', 0, 0),
       (4, 'size', 'XL', 0, 0),
       (5, 'color', 'Black', 0, 0),
       (6, 'color', 'White', 0, 0),
       (7, 'color', 'Blue', 0, 0),
       (8, 'color', 'Red', 0, 0),
       (9, 'color', 'Gray', 0, 0),
       (10, 'color', 'Green', 0, 0);

-- ---------------------------------------------------------------------------
-- Warehouses (3)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO warehouse (warehouse_id, name, location, address, created_by, modified_by)
VALUES (1, 'Kyiv Main', 'Kyiv region', 'Kyiv, Industrialna 1', 0, 0),
       (2, 'Lviv Warehouse', 'Lviv region', 'Lviv, Stryiska 10', 0, 0),
       (3, 'Odesa Port', 'Odesa region', 'Odesa, Port 5', 0, 0);

-- ---------------------------------------------------------------------------
-- Delivery methods (5)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO delivery_method (delivery_method_id, name, code, description, is_active, created_by, modified_by)
VALUES (1, 'Nova Poshta', 'nova_poshta', 'Courier Nova Poshta', 1, 0, 0),
       (2, 'Ukrposhta', 'ukrposhta', 'National postal', 1, 0, 0),
       (3, 'Pickup', 'pickup', 'Store pickup', 1, 0, 0),
       (4, 'Express', 'express', 'Same day', 1, 0, 0),
       (5, 'Supplier truck', 'supplier_truck', 'Supplier delivery to warehouse', 1, 0, 0);

-- ---------------------------------------------------------------------------
-- Payment methods (3)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO payment_method (payment_method_id, name, code, is_active, created_by, modified_by)
VALUES (1, 'Card', 'card', 1, 0, 0),
       (2, 'Cash on delivery', 'cod', 1, 0, 0),
       (3, 'PayPal', 'paypal', 1, 0, 0);

-- ---------------------------------------------------------------------------
-- Suppliers (5)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO supplier (supplier_id, name, contact_info, email, phone, created_by, modified_by)
VALUES (1, 'TechSupplier Ltd', 'Contact: John', 'tech@supplier.com', '+380501234567', 0, 0),
       (2, 'Global Electronics', 'Sales dept', 'sales@globalelectro.com', '+380672345678', 0, 0),
       (3, 'HomeGoods Inc', 'Procurement', 'proc@homegoods.com', '+380933456789', 0, 0),
       (4, 'SportWholesale', 'Warehouse', 'warehouse@sportws.com', '+380504567890', 0, 0),
       (5, 'BookDistributor', 'Orders', 'orders@bookdist.com', '+380635678901', 0, 0);
