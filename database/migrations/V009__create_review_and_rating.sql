-- V009: review, rating. System fields + FK to user for created_by, modified_by.

CREATE TABLE IF NOT EXISTS review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comment TEXT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    CHECK (rating >= 1 AND rating <= 5),
    UNIQUE KEY uk_review_user_product (user_id, product_id),
    INDEX idx_review_product_id (product_id),
    INDEX idx_review_rating (rating),
    INDEX idx_review_deleted_dt (deleted_dt),
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_review_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Product reviews';

CREATE TABLE IF NOT EXISTS rating (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    value TINYINT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    CHECK (value >= 1 AND value <= 5),
    INDEX idx_rating_product_id (product_id),
    INDEX idx_rating_deleted_dt (deleted_dt),
    CONSTRAINT fk_rating_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_rating_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_rating_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_rating_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Product ratings';
