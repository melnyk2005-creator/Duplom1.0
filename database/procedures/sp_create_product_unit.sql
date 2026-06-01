-- Create one serialized unit (one row per physical item). Serial number must be unique globally.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_product_unit$$
CREATE PROCEDURE sp_create_product_unit(
    IN p_product_sku_id INT,
    IN p_warehouse_id INT,
    IN p_serial_number VARCHAR(100),
    IN p_manufacture_date DATE,
    IN p_article VARCHAR(100),
    IN p_imei VARCHAR(50),
    IN p_batch_number VARCHAR(100),
    IN p_tracking_info TEXT,
    IN p_created_by BIGINT,
    OUT p_product_unit_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_product_unit: Create serialized unit';
    INSERT INTO product_unit (
        product_sku_id, warehouse_id, serial_number, manufacture_date, article, imei, batch_number, tracking_info,
        created_by, modified_by
    ) VALUES (
        p_product_sku_id, p_warehouse_id, p_serial_number, p_manufacture_date, p_article, p_imei, p_batch_number, p_tracking_info,
        p_created_by, p_created_by
    );
    SET p_product_unit_id = LAST_INSERT_ID();
END$$
DELIMITER ;
