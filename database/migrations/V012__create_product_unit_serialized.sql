-- V012: Serialized unit level. product_unit = one row per physical unit (serial, manufacture date, article, etc.).

CREATE TABLE IF NOT EXISTS product_unit (
    product_unit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_sku_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    serial_number VARCHAR(100) NOT NULL,
    manufacture_date DATE NULL,
    article VARCHAR(100) NULL COMMENT 'Articul / internal article number',
    imei VARCHAR(50) NULL COMMENT 'International Mobile Equipment Identity',
    batch_number VARCHAR(100) NULL,
    tracking_info TEXT NULL COMMENT 'Other tracking data (JSON or free text)',
    order_item_id INT NULL COMMENT 'When set: unit allocated/sold to this order line',
    order_shipment_item_id INT NULL COMMENT 'When set: unit shipped in this order shipment line',
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_product_unit_sku_serial (product_sku_id, serial_number) COMMENT 'Serial unique per SKU',
    INDEX idx_product_unit_product_sku_warehouse (product_sku_id, warehouse_id),
    INDEX idx_product_unit_order_item_id (order_item_id),
    INDEX idx_product_unit_deleted_dt (deleted_dt),
    CONSTRAINT fk_product_unit_product_sku FOREIGN KEY (product_sku_id) REFERENCES product_sku(product_sku_id) ON DELETE CASCADE,
    CONSTRAINT fk_product_unit_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    CONSTRAINT fk_product_unit_order_item FOREIGN KEY (order_item_id) REFERENCES order_item(order_item_id) ON DELETE SET NULL,
    CONSTRAINT fk_product_unit_order_shipment_item FOREIGN KEY (order_shipment_item_id) REFERENCES order_shipment_item(order_shipment_item_id) ON DELETE SET NULL,
    CONSTRAINT fk_product_unit_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_product_unit_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'One row per physical unit; serial_number unique per product_sku (different SKUs can reuse same serial)';

CREATE TABLE IF NOT EXISTS product_unit_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_unit_id INT NOT NULL,
    product_sku_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    serial_number VARCHAR(100) NOT NULL,
    manufacture_date DATE NULL,
    article VARCHAR(100) NULL,
    imei VARCHAR(50) NULL,
    batch_number VARCHAR(100) NULL,
    tracking_info TEXT NULL,
    order_item_id INT NULL,
    order_shipment_item_id INT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NULL,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NULL,
    deleted_dt TIMESTAMP NULL,
    action_description VARCHAR(255) NOT NULL,
    effective_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_unit_history_product_unit_id (product_unit_id),
    INDEX idx_product_unit_history_effective_dt (effective_dt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'History for product_unit';
