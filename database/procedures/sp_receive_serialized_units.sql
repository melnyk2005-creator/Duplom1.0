-- Receive multiple serialized units in one call. p_items: JSON array e.g.
-- [{"product_sku_id":1,"warehouse_id":1,"serial_number":"SN001","manufacture_date":"2024-01-15","article":"ART-001","imei":"123456789"}]

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_receive_serialized_units$$
CREATE PROCEDURE sp_receive_serialized_units(
    IN p_items JSON,
    IN p_created_by BIGINT,
    OUT p_count INT
)
BEGIN
    SET p_count = 0;
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_receive_serialized_units: Receive serialized units';

    IF p_items IS NULL OR JSON_LENGTH(p_items) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'sp_receive_serialized_units: items required';
    END IF;

    INSERT INTO product_unit (product_sku_id, warehouse_id, serial_number, manufacture_date, article, imei,
                              batch_number, tracking_info,
                              created_by, modified_by)
    SELECT j.product_sku_id,
           j.warehouse_id,
           j.serial_number,
           j.manufacture_date,
           j.article,
           j.imei,
           j.batch_number,
           j.tracking_info,
           p_created_by,
           p_created_by
    FROM JSON_TABLE(
                 p_items,
                 '$[*]' COLUMNS (
                     product_sku_id INT PATH '$.product_sku_id',
                     warehouse_id INT PATH '$.warehouse_id',
                     serial_number VARCHAR(100) PATH '$.serial_number',
                     manufacture_date DATE PATH '$.manufacture_date',
                     article VARCHAR(100) PATH '$.article',
                     imei VARCHAR(50) PATH '$.imei',
                     batch_number VARCHAR(100) PATH '$.batch_number',
                     tracking_info TEXT PATH '$.tracking_info'
                     )
         ) AS j
    WHERE j.product_sku_id IS NOT NULL
      AND j.warehouse_id IS NOT NULL
      AND j.serial_number IS NOT NULL
      AND j.serial_number != '';

    SET p_count = ROW_COUNT();
END$$
DELIMITER ;
