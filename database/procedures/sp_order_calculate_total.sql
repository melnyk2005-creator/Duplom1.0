-- Recalculate order total from order_item (sum of quantity * price).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_order_calculate_total$$
CREATE PROCEDURE sp_order_calculate_total(IN p_order_id INT)
BEGIN
    SET @current_action_desc = 'sp_order_calculate_total: Recalculate order total';
    UPDATE `order` o
    SET o.total_amount = (
        SELECT COALESCE(SUM(oi.quantity * oi.price), 0)
        FROM order_item oi
        WHERE oi.order_id = p_order_id AND oi.deleted_dt IS NULL
    ),
    o.modified_dt = CURRENT_TIMESTAMP
    WHERE o.order_id = p_order_id;
END$$
DELIMITER ;
