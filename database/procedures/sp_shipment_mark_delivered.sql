-- Mark order_shipment as delivered (set delivered_date and status = 4).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_shipment_mark_delivered$$
CREATE PROCEDURE sp_shipment_mark_delivered(
    IN p_order_shipment_id INT,
    IN p_modified_by BIGINT
)
BEGIN
    SET p_modified_by = COALESCE(p_modified_by, 0);
    SET @current_action_desc = 'sp_shipment_mark_delivered: Mark order shipment delivered';

    UPDATE order_shipment
    SET delivered_date     = CURRENT_TIMESTAMP,
        shipment_status_id = 4,
        modified_by        = p_modified_by,
        modified_dt        = CURRENT_TIMESTAMP
    WHERE order_shipment_id = p_order_shipment_id
      AND deleted_dt IS NULL;
END$$
DELIMITER ;
