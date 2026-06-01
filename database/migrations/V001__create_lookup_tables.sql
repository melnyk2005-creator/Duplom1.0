-- V001: Lookup tables (replace ENUMs). PK = table_name_id. System fields (no FK to user yet).

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE TABLE IF NOT EXISTS user_status (
    user_status_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_user_status_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'User status lookup (active, inactive)';

CREATE TABLE IF NOT EXISTS order_status (
    order_status_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_order_status_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Order status lookup';

CREATE TABLE IF NOT EXISTS payment_status (
    payment_status_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_payment_status_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Payment status lookup';

CREATE TABLE IF NOT EXISTS coupon_discount_type (
    coupon_discount_type_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_coupon_discount_type_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Coupon discount type (amount, percent)';

CREATE TABLE IF NOT EXISTS purchase_order_status (
    purchase_order_status_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_purchase_order_status_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Purchase order status (we order from supplier)';

CREATE TABLE IF NOT EXISTS shipment_status (
    shipment_status_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_shipment_status_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Shipment status lookup';

CREATE TABLE IF NOT EXISTS log_level (
    log_level_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_log_level_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'System log level lookup';

CREATE TABLE IF NOT EXISTS audit_action (
    audit_action_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_audit_action_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Audit action (INSERT, UPDATE, DELETE)';

-- Seed lookup data (required for FKs)
INSERT IGNORE INTO user_status (user_status_id, code, name) VALUES (1, 'active', 'Active'), (2, 'inactive', 'Inactive');
INSERT IGNORE INTO order_status (order_status_id, code, name) VALUES (1,'pending','Pending'),(2,'paid','Paid'),(3,'processing','Processing'),(4,'shipped','Shipped'),(5,'delivered','Delivered'),(6,'cancelled','Cancelled');
INSERT IGNORE INTO payment_status (payment_status_id, code, name) VALUES (1,'pending','Pending'),(2,'completed','Completed'),(3,'failed','Failed'),(4,'refunded','Refunded');
INSERT IGNORE INTO coupon_discount_type (coupon_discount_type_id, code, name) VALUES (1,'amount','Amount'),(2,'percent','Percent');
INSERT IGNORE INTO purchase_order_status (purchase_order_status_id, code, name) VALUES (1,'draft','Draft'),(2,'ordered','Ordered'),(3,'in_transit','In Transit'),(4,'received','Received'),(5,'cancelled','Cancelled');
INSERT IGNORE INTO shipment_status (shipment_status_id, code, name) VALUES (1,'pending','Pending'),(2,'shipped','Shipped'),(3,'in_transit','In Transit'),(4,'delivered','Delivered');
INSERT IGNORE INTO log_level (log_level_id, code, name) VALUES (1,'DEBUG','Debug'),(2,'INFO','Info'),(3,'WARNING','Warning'),(4,'ERROR','Error'),(5,'CRITICAL','Critical');
INSERT IGNORE INTO audit_action (audit_action_id, code, name) VALUES (1,'INSERT','Insert'),(2,'UPDATE','Update'),(3,'DELETE','Delete');
