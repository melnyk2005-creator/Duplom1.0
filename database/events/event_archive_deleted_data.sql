-- Event: move soft-deleted rows (deleted_dt set) older than 1 year from main schema into archive schema.
-- Requires archive schema and archive tables to exist (same structure as main, no FK to main).
-- Run in main schema (e.g. ecommerce). Ensure event_scheduler is ON: SET GLOBAL event_scheduler = ON;

-- Prerequisite: create archive tables in ecommerce_archive (same DDL as main but without FK to main).
-- This event INSERTs into ecommerce_archive.<table> from ecommerce.<table> WHERE deleted_dt IS NOT NULL AND deleted_dt < DATE_SUB(NOW(), INTERVAL 1 YEAR),
-- then DELETEs those rows from ecommerce.<table>.

DELIMITER //

DROP EVENT IF EXISTS event_archive_deleted_data//
CREATE EVENT event_archive_deleted_data
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
COMMENT 'Move soft-deleted records older than 1 year to archive schema'
DO
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tname VARCHAR(64);
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME IN (
            'user', 'address', 'category', 'sub_category', 'brand', 'product', 'product_attribute', 'product_sku',
            'order', 'order_item', 'cart', 'cart_item', 'wishlist', 'wishlist_item',
            'payment_method', 'payment', 'coupon', 'coupon_redemption',
            'warehouse', 'inventory', 'product_unit', 'supplier', 'supplier_product', 'delivery_method', 'order_shipment', 'order_shipment_item', 'purchase_order', 'purchase_order_item',
            'review', 'rating'
          );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO tname;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @sql_ins = CONCAT(
            'INSERT IGNORE INTO ecommerce_archive.`', tname, '` SELECT * FROM `', tname, '`',
            ' WHERE deleted_dt IS NOT NULL AND deleted_dt < DATE_SUB(NOW(), INTERVAL 1 YEAR)'
        );
        PREPARE stmt_ins FROM @sql_ins;
        EXECUTE stmt_ins;
        DEALLOCATE PREPARE stmt_ins;

        SET @sql_del = CONCAT(
            'DELETE FROM `', tname, '`',
            ' WHERE deleted_dt IS NOT NULL AND deleted_dt < DATE_SUB(NOW(), INTERVAL 1 YEAR)'
        );
        PREPARE stmt_del FROM @sql_del;
        EXECUTE stmt_del;
        DEALLOCATE PREPARE stmt_del;
    END LOOP;
    CLOSE cur;
END//

DELIMITER ;
