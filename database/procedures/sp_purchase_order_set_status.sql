-- Set purchase order status (1=draft, 2=ordered, 3=in_transit, 4=received, 5=cancelled).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_purchase_order_set_status$$
CREATE PROCEDURE sp_purchase_order_set_status(
    IN p_purchase_order_id INT,
    IN p_purchase_order_status_id INT,
    IN p_modified_by BIGINT
)
BEGIN
    SET p_modified_by = COALESCE(p_modified_by, 0);
    SET @current_action_desc = 'sp_purchase_order_set_status: Set purchase order status';
    UPDATE purchase_order
    SET purchase_order_status_id = p_purchase_order_status_id,
        modified_by              = p_modified_by,
        modified_dt              = CURRENT_TIMESTAMP
    WHERE purchase_order_id = p_purchase_order_id
      AND deleted_dt IS NULL;
END$$
DELIMITER ;
