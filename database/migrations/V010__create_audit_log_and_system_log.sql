-- V010: audit_log, system_log. System fields + FK to user for created_by, modified_by. audit_action_id, log_level_id.

CREATE TABLE IF NOT EXISTS audit_log (
    audit_log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id VARCHAR(100) NOT NULL,
    audit_action_id INT NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    changed_by BIGINT NULL,
    changed_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_audit_log_table_record (table_name, record_id),
    INDEX idx_audit_log_changed_dt (changed_dt),
    INDEX idx_audit_log_audit_action_id (audit_action_id),
    CONSTRAINT fk_audit_log_audit_action FOREIGN KEY (audit_action_id) REFERENCES audit_action(audit_action_id) ON DELETE RESTRICT,
    CONSTRAINT fk_audit_log_changed_by FOREIGN KEY (changed_by) REFERENCES user(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_audit_log_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_audit_log_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Audit trail';

CREATE TABLE IF NOT EXISTS system_log (
    system_log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    log_level_id INT NOT NULL,
    message TEXT NULL,
    context JSON NULL,
    source VARCHAR(255) NULL,
    created_by BIGINT NOT NULL DEFAULT 0,
    created_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by BIGINT NOT NULL DEFAULT 0,
    modified_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_dt TIMESTAMP NULL,
    INDEX idx_system_log_log_level_id (log_level_id),
    INDEX idx_system_log_created_dt (created_dt),
    CONSTRAINT fk_system_log_log_level FOREIGN KEY (log_level_id) REFERENCES log_level(log_level_id) ON DELETE RESTRICT,
    CONSTRAINT fk_system_log_created_by FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_system_log_modified_by FOREIGN KEY (modified_by) REFERENCES user(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'System event and error logs';
