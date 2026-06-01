-- V007: payment_method, payment, coupon, coupon_redemption. System fields + FK to user. Lookup FKs use table_name_id.

CREATE TABLE IF NOT EXISTS payment_method (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(30) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_payment_method_code (code),
    INDEX idx_payment_method_deleted_dt (deleted_dt),
    CONSTRAINT fk_payment_method_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_method_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Payment methods';

CREATE TABLE IF NOT EXISTS payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method_id INT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_status_id INT NOT NULL,
    external_id VARCHAR(100) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_payment_order_id (order_id),
    INDEX idx_payment_status_id (payment_status_id),
    INDEX idx_payment_created_dt (created_dt),
    INDEX idx_payment_deleted_dt (deleted_dt),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES `order`(order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_method(payment_method_id) ON DELETE SET NULL,
    CONSTRAINT fk_payment_status FOREIGN KEY (payment_status_id) REFERENCES payment_status(payment_status_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Payments';

CREATE TABLE IF NOT EXISTS coupon (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
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
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_coupon_code (code),
    INDEX idx_coupon_valid (valid_from, valid_to),
    INDEX idx_coupon_deleted_dt (deleted_dt),
    CONSTRAINT fk_coupon_discount_type FOREIGN KEY (coupon_discount_type_id) REFERENCES coupon_discount_type(coupon_discount_type_id) ON DELETE RESTRICT,
    CONSTRAINT fk_coupon_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_coupon_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Coupons';

CREATE TABLE IF NOT EXISTS coupon_redemption (
    coupon_redemption_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    order_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    discount_applied DECIMAL(12, 2) NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_coupon_redemption_coupon_id (coupon_id),
    INDEX idx_coupon_redemption_order_id (order_id),
    INDEX idx_coupon_redemption_deleted_dt (deleted_dt),
    CONSTRAINT fk_coupon_redemption_coupon FOREIGN KEY (coupon_id) REFERENCES coupon(coupon_id) ON DELETE RESTRICT,
    CONSTRAINT fk_coupon_redemption_order FOREIGN KEY (order_id) REFERENCES `order`(order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_coupon_redemption_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_coupon_redemption_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_coupon_redemption_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Coupon redemptions';
