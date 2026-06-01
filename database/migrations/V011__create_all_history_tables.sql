-- V011: History tables for each main table. Same structure as main + history_id, action_description, effective_dt.

CREATE TABLE IF NOT EXISTS user_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    user_status_id INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_history_user_id (user_id),
    INDEX idx_user_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for user';

CREATE TABLE IF NOT EXISTS address_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    address_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NULL,
    country VARCHAR(100) NOT NULL,
    is_default TINYINT(1) DEFAULT 0,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_address_history_address_id (address_id),
    INDEX idx_address_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for address';

CREATE TABLE IF NOT EXISTS category_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) NOT NULL,
    description TEXT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category_history_category_id (category_id),
    INDEX idx_category_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for category';

CREATE TABLE IF NOT EXISTS sub_category_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sub_category_id INT NOT NULL,
    parent_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sub_category_history_sub_category_id (sub_category_id),
    INDEX idx_sub_category_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for sub_category';

CREATE TABLE IF NOT EXISTS brand_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    brand_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) NOT NULL,
    description TEXT NULL,
    logo_url VARCHAR(500) NULL,
    website_url VARCHAR(500) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_brand_history_brand_id (brand_id),
    INDEX idx_brand_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for brand';

CREATE TABLE IF NOT EXISTS product_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    short_description VARCHAR(500) NULL,
    category_id INT NULL,
    sub_category_id INT NULL,
    brand_id INT NULL,
    stock_quantity INT DEFAULT 0,
    weight_kg DECIMAL(10, 3) NULL,
    length_cm DECIMAL(10, 2) NULL,
    width_cm DECIMAL(10, 2) NULL,
    height_cm DECIMAL(10, 2) NULL,
    is_featured TINYINT(1) DEFAULT 0,
    meta_title VARCHAR(255) NULL,
    meta_description TEXT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_history_product_id (product_id),
    INDEX idx_product_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for product';

CREATE TABLE IF NOT EXISTS product_attribute_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_attribute_id INT NOT NULL,
    attribute_type VARCHAR(50) NOT NULL,
    attribute_value VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_attribute_history_product_attribute_id (product_attribute_id),
    INDEX idx_product_attribute_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for product_attribute';

CREATE TABLE IF NOT EXISTS product_sku_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_sku_id INT NOT NULL,
    product_id INT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    size_attribute_id INT NULL,
    color_attribute_id INT NULL,
    price DECIMAL(12, 2) NOT NULL,
    is_serialized TINYINT(1) NOT NULL DEFAULT 0,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_sku_history_product_sku_id (product_sku_id),
    INDEX idx_product_sku_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for product_sku';

CREATE TABLE IF NOT EXISTS order_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    order_status_id INT NOT NULL,
    shipping_address_id INT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_history_order_id (order_id),
    INDEX idx_order_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for order';

CREATE TABLE IF NOT EXISTS order_item_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_sku_id INT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_item_history_order_item_id (order_item_id),
    INDEX idx_order_item_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for order_item';

CREATE TABLE IF NOT EXISTS cart_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    total DECIMAL(12, 2) DEFAULT 0.00,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_cart_history_cart_id (cart_id),
    INDEX idx_cart_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for cart';

CREATE TABLE IF NOT EXISTS cart_item_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_item_id INT NOT NULL,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    product_sku_id INT NULL,
    quantity INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_cart_item_history_cart_item_id (cart_item_id),
    INDEX idx_cart_item_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for cart_item';

CREATE TABLE IF NOT EXISTS wishlist_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wishlist_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    name VARCHAR(100) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_wishlist_history_wishlist_id (wishlist_id),
    INDEX idx_wishlist_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for wishlist';

CREATE TABLE IF NOT EXISTS wishlist_item_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wishlist_item_id INT NOT NULL,
    wishlist_id INT NOT NULL,
    product_id INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_wishlist_item_history_wishlist_item_id (wishlist_item_id),
    INDEX idx_wishlist_item_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for wishlist_item';

CREATE TABLE IF NOT EXISTS payment_method_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_method_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(30) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_payment_method_history_payment_method_id (payment_method_id),
    INDEX idx_payment_method_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for payment_method';

CREATE TABLE IF NOT EXISTS payment_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL,
    order_id INT NOT NULL,
    payment_method_id INT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_status_id INT NOT NULL,
    external_id VARCHAR(100) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_payment_history_payment_id (payment_id),
    INDEX idx_payment_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for payment';

CREATE TABLE IF NOT EXISTS coupon_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    code VARCHAR(50) NOT NULL,
    coupon_discount_type_id INT NOT NULL,
    discount_amount DECIMAL(12, 2) NULL,
    discount_percent DECIMAL(5, 2) NULL,
    valid_from TIMESTAMP NULL,
    valid_to TIMESTAMP NULL,
    max_uses INT NULL,
    used_count INT DEFAULT 0,
    min_order_amount DECIMAL(12, 2) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_coupon_history_coupon_id (coupon_id),
    INDEX idx_coupon_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for coupon';

CREATE TABLE IF NOT EXISTS coupon_redemption_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    coupon_redemption_id INT NOT NULL,
    coupon_id INT NOT NULL,
    order_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    discount_applied DECIMAL(12, 2) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_coupon_redemption_history_coupon_redemption_id (coupon_redemption_id),
    INDEX idx_coupon_redemption_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for coupon_redemption';

CREATE TABLE IF NOT EXISTS warehouse_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    location VARCHAR(255) NULL,
    address VARCHAR(255) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_warehouse_history_warehouse_id (warehouse_id),
    INDEX idx_warehouse_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for warehouse';

CREATE TABLE IF NOT EXISTS inventory_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT NOT NULL,
    product_sku_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_inventory_history_inventory_id (inventory_id),
    INDEX idx_inventory_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for inventory';

CREATE TABLE IF NOT EXISTS supplier_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    contact_info VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(50) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_supplier_history_supplier_id (supplier_id),
    INDEX idx_supplier_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for supplier';

CREATE TABLE IF NOT EXISTS supplier_product_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    supplier_sku VARCHAR(100) NULL,
    cost_price DECIMAL(12, 2) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_supplier_product_history_supplier_product (supplier_id, product_id),
    INDEX idx_supplier_product_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for supplier_product';

CREATE TABLE IF NOT EXISTS delivery_method_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    delivery_method_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(255) NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(255) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_delivery_method_history_delivery_method_id (delivery_method_id),
    INDEX idx_delivery_method_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for delivery_method';

CREATE TABLE IF NOT EXISTS order_shipment_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_shipment_id INT NOT NULL,
    order_id INT NOT NULL,
    warehouse_id INT NULL,
    delivery_method_id INT NULL,
    tracking_number VARCHAR(100) NULL,
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    shipment_status_id INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(255) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_shipment_history_order_shipment_id (order_shipment_id),
    INDEX idx_order_shipment_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for order_shipment';

CREATE TABLE IF NOT EXISTS order_shipment_item_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_shipment_item_id INT NOT NULL,
    order_shipment_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(255) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_shipment_item_history_order_shipment_item_id (order_shipment_item_id),
    INDEX idx_order_shipment_item_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for order_shipment_item';

CREATE TABLE IF NOT EXISTS purchase_order_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    delivery_method_id INT NULL,
    purchase_order_status_id INT NOT NULL,
    order_date DATE NULL,
    expected_delivery_date DATE NULL,
    notes TEXT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(255) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_purchase_order_history_purchase_order_id (purchase_order_id),
    INDEX idx_purchase_order_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for purchase_order';

CREATE TABLE IF NOT EXISTS purchase_order_item_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_item_id INT NOT NULL,
    purchase_order_id INT NOT NULL,
    product_sku_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(12, 2) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(255) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_purchase_order_item_history_purchase_order_item_id (purchase_order_item_id),
    INDEX idx_purchase_order_item_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for purchase_order_item';

CREATE TABLE IF NOT EXISTS review_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    review_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comment TEXT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_review_history_review_id (review_id),
    INDEX idx_review_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for review';

CREATE TABLE IF NOT EXISTS rating_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rating_id INT NOT NULL,
    product_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    value TINYINT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(20) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rating_history_rating_id (rating_id),
    INDEX idx_rating_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for rating';
