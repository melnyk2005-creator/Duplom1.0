-- V008: warehouse, inventory, supplier, supplier_product, delivery_method, order_shipment (we send to customer), order_shipment_item, purchase_order (we order from supplier), purchase_order_item. System fields + FK to user.

CREATE TABLE IF NOT EXISTS warehouse (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location VARCHAR(255) NULL,
    address VARCHAR(255) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_warehouse_name (name),
    INDEX idx_warehouse_deleted_dt (deleted_dt),
    CONSTRAINT fk_warehouse_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_warehouse_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Warehouses';

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_sku_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    CHECK (quantity >= 0),
    UNIQUE KEY uk_inventory_product_sku_warehouse (product_sku_id, warehouse_id),
    INDEX idx_inventory_warehouse_id (warehouse_id),
    INDEX idx_inventory_deleted_dt (deleted_dt),
    CONSTRAINT fk_inventory_product_sku FOREIGN KEY (product_sku_id) REFERENCES product_sku(product_sku_id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Stock per product_sku per warehouse (single source of truth for quantity)';

CREATE TABLE IF NOT EXISTS supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_info VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(50) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_supplier_name (name),
    INDEX idx_supplier_deleted_dt (deleted_dt),
    CONSTRAINT fk_supplier_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_supplier_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Suppliers';

CREATE TABLE IF NOT EXISTS supplier_product (
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    supplier_sku VARCHAR(100) NULL,
    cost_price DECIMAL(12, 2) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    PRIMARY KEY (supplier_id, product_id),
    INDEX idx_supplier_product_product_id (product_id),
    INDEX idx_supplier_product_deleted_dt (deleted_dt),
    CONSTRAINT fk_supplier_product_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON DELETE CASCADE,
    CONSTRAINT fk_supplier_product_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_supplier_product_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_supplier_product_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Supplier-product (M:N)';

CREATE TABLE IF NOT EXISTS delivery_method (
    delivery_method_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(255) NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_delivery_method_code (code),
    INDEX idx_delivery_method_deleted_dt (deleted_dt),
    CONSTRAINT fk_delivery_method_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_delivery_method_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Delivery/shipping method (courier, pickup, etc.)';

CREATE TABLE IF NOT EXISTS order_shipment (
    order_shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    warehouse_id INT NULL COMMENT 'Warehouse from which we ship (one per shipment)',
    delivery_method_id INT NULL COMMENT 'How we send to customer',
    tracking_number VARCHAR(100) NULL,
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    shipment_status_id INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_order_shipment_order_id (order_id),
    INDEX idx_order_shipment_warehouse_id (warehouse_id),
    INDEX idx_order_shipment_tracking (tracking_number),
    INDEX idx_order_shipment_status_id (shipment_status_id),
    INDEX idx_order_shipment_deleted_dt (deleted_dt),
    CONSTRAINT fk_order_shipment_order FOREIGN KEY (order_id) REFERENCES `order`(order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_shipment_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id) ON DELETE SET NULL,
    CONSTRAINT fk_order_shipment_delivery_method FOREIGN KEY (delivery_method_id) REFERENCES delivery_method(delivery_method_id) ON DELETE SET NULL,
    CONSTRAINT fk_order_shipment_status FOREIGN KEY (shipment_status_id) REFERENCES shipment_status(shipment_status_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_shipment_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_shipment_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Outbound: we send goods to customer (from one warehouse, one delivery method)';

CREATE TABLE IF NOT EXISTS order_shipment_item (
    order_shipment_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_shipment_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_order_shipment_item_order_shipment_id (order_shipment_id),
    INDEX idx_order_shipment_item_deleted_dt (deleted_dt),
    CONSTRAINT fk_order_shipment_item_order_shipment FOREIGN KEY (order_shipment_id) REFERENCES order_shipment(order_shipment_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_shipment_item_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_shipment_item_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_shipment_item_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Outbound shipment line items';

CREATE TABLE IF NOT EXISTS purchase_order (
    purchase_order_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL COMMENT 'Destination: where goods should arrive',
    delivery_method_id INT NULL COMMENT 'How supplier delivers to us',
    purchase_order_status_id INT NOT NULL,
    order_date DATE NULL,
    expected_delivery_date DATE NULL,
    notes TEXT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_purchase_order_supplier_id (supplier_id),
    INDEX idx_purchase_order_warehouse_id (warehouse_id),
    INDEX idx_purchase_order_status_id (purchase_order_status_id),
    INDEX idx_purchase_order_deleted_dt (deleted_dt),
    CONSTRAINT fk_purchase_order_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_delivery_method FOREIGN KEY (delivery_method_id) REFERENCES delivery_method(delivery_method_id) ON DELETE SET NULL,
    CONSTRAINT fk_purchase_order_status FOREIGN KEY (purchase_order_status_id) REFERENCES purchase_order_status(purchase_order_status_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Inbound: we order from supplier; goods go to warehouse';

CREATE TABLE IF NOT EXISTS purchase_order_item (
    purchase_order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    product_sku_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(12, 2) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_purchase_order_item_purchase_order_id (purchase_order_id),
    INDEX idx_purchase_order_item_deleted_dt (deleted_dt),
    CONSTRAINT fk_purchase_order_item_purchase_order FOREIGN KEY (purchase_order_id) REFERENCES purchase_order(purchase_order_id) ON DELETE CASCADE,
    CONSTRAINT fk_purchase_order_item_product_sku FOREIGN KEY (product_sku_id) REFERENCES product_sku(product_sku_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_item_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_item_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Purchase order line items';
