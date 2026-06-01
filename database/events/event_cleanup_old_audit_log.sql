-- Event: delete audit_log rows older than 2 years (run in main schema).

DELIMITER //

DROP EVENT IF EXISTS event_cleanup_old_audit_log//
CREATE EVENT event_cleanup_old_audit_log
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM audit_log WHERE changed_dt < DATE_SUB(NOW(), INTERVAL 2 YEAR);
END//

DELIMITER ;
