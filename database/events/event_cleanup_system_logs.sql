-- Event: delete system_log rows older than 90 days (run in main schema).

DELIMITER //

DROP EVENT IF EXISTS event_cleanup_system_logs//
CREATE EVENT event_cleanup_system_logs
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM system_log WHERE created_dt < DATE_SUB(NOW(), INTERVAL 90 DAY);
END//

DELIMITER ;
