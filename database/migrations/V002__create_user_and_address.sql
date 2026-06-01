-- V002: User and address. System fields + FK to user for created_by, modified_by. Insert SYSTEM user (user_id=0) then add self-FK on user.

CREATE TABLE IF NOT EXISTS user (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    user_status_id INT NOT NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    UNIQUE KEY uk_user_username (username),
    UNIQUE KEY uk_user_email (email),
    INDEX idx_user_status_id (user_status_id),
    INDEX idx_user_created_dt (created_dt),
    INDEX idx_user_deleted_dt (deleted_dt),
    CONSTRAINT fk_user_status FOREIGN KEY (user_status_id) REFERENCES user_status(user_status_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'System users';

-- SYSTEM user (user_id=0) for created_by/modified_by when no real user
INSERT IGNORE INTO user (user_id, username, email, password_hash, user_status_id, created_by, modified_by)
VALUES (0, 'SYSTEM', 'system@internal', '', 1, 0, 0);

-- Point invalid created_by/modified_by to SYSTEM (0) so FK constraint can be added
CREATE TEMPORARY TABLE _valid_user_ids AS SELECT user_id FROM user;
UPDATE user u
LEFT JOIN _valid_user_ids cr ON u.created_by = cr.user_id
SET u.created_by = 0
WHERE cr.user_id IS NULL;
UPDATE user u
LEFT JOIN _valid_user_ids mo ON u.modified_by = mo.user_id
SET u.modified_by = 0
WHERE mo.user_id IS NULL;
DROP TEMPORARY TABLE _valid_user_ids;

ALTER TABLE user
    ADD CONSTRAINT fk_user_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_user_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT;

CREATE TABLE IF NOT EXISTS address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'Ukraine',
    is_default TINYINT(1) DEFAULT 0,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_address_user_id (user_id),
    INDEX idx_address_city (city),
    INDEX idx_address_deleted_dt (deleted_dt),
    CONSTRAINT fk_address_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_address_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_address_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'User addresses';
