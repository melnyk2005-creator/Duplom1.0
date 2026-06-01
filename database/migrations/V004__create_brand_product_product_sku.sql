-- V004: Brand, product, product_attribute, product_sku. System fields + FK to user for created_by, modified_by.

CREATE TABLE IF NOT EXISTS brand (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) NOT NULL,
    description TEXT NULL,
    logo_url VARCHAR(500) NULL,
    website_url VARCHAR(500) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_brand_slug (slug),
    INDEX idx_brand_name (name),
    INDEX idx_brand_deleted_dt (deleted_dt),
    CONSTRAINT fk_brand_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_brand_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Product brands';

CREATE TABLE IF NOT EXISTS product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
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
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_product_category_id (category_id),
    INDEX idx_product_brand_id (brand_id),
    INDEX idx_product_name (name),
    INDEX idx_product_deleted_dt (deleted_dt),
    INDEX idx_product_is_featured (is_featured),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE SET NULL,
    CONSTRAINT fk_product_sub_category FOREIGN KEY (sub_category_id) REFERENCES sub_category(sub_category_id) ON DELETE SET NULL,
    CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES brand(brand_id) ON DELETE SET NULL,
    CONSTRAINT fk_product_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_product_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Products';

CREATE TABLE IF NOT EXISTS product_attribute (
    product_attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_type VARCHAR(50) NOT NULL,
    attribute_value VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_product_attribute_type_value (attribute_type, attribute_value),
    INDEX idx_product_attribute_deleted_dt (deleted_dt),
    CONSTRAINT fk_product_attribute_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_product_attribute_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Product attributes';

CREATE TABLE IF NOT EXISTS product_sku (
    product_sku_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    size_attribute_id INT NULL,
    color_attribute_id INT NULL,
    price DECIMAL(12, 2) NOT NULL,
    is_serialized TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = track by product_unit (serial number etc.); 0 = use inventory quantity only',
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_product_sku_code (sku),
    INDEX idx_product_sku_product_id (product_id),
    INDEX idx_product_sku_deleted_dt (deleted_dt),
    CONSTRAINT fk_product_sku_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_product_sku_size FOREIGN KEY (size_attribute_id) REFERENCES product_attribute(product_attribute_id) ON DELETE SET NULL,
    CONSTRAINT fk_product_sku_color FOREIGN KEY (color_attribute_id) REFERENCES product_attribute(product_attribute_id) ON DELETE SET NULL,
    CONSTRAINT fk_product_sku_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_product_sku_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Product SKUs (price per variant); quantity only in inventory per warehouse';
