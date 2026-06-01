-- Set order status (e.g. pending=1, paid=2, processing=3, shipped=4, delivered=5, cancelled=6).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_order_set_status$$
CREATE PROCEDURE sp_order_set_status(
    IN p_order_id INT,
    IN p_order_status_id INT,
    IN p_modified_by BIGINT
)
BEGIN
    SET p_modified_by = COALESCE(p_modified_by, 0);
    SET @current_action_desc = 'sp_order_set_status: Set order status';

    UPDATE `order`
    SET order_status_id = p_order_status_id, modified_by = p_modified_by, modified_dt = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id AND deleted_dt IS NULL;
END$$
DELIMITER ;
