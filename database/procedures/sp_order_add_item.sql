-- Add line item to order. Price is passed (e.g. from product_sku at order time). Optionally recalc order total.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_order_add_item$$
CREATE PROCEDURE sp_order_add_item(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_product_sku_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(12,2),
    IN p_created_by BIGINT,
    IN p_recalc_total TINYINT,
    OUT p_order_item_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET p_recalc_total = COALESCE(p_recalc_total, 1);
    SET p_quantity = GREATEST(1, p_quantity);
    SET @current_action_desc = 'sp_order_add_item: Add order line item';

    INSERT INTO order_item (order_id, product_id, product_sku_id, quantity, price, created_by, modified_by)
    VALUES (p_order_id, p_product_id, p_product_sku_id, p_quantity, p_price, p_created_by, p_created_by);
    SET p_order_item_id = LAST_INSERT_ID();

    IF p_recalc_total = 1 THEN
        CALL sp_order_calculate_total(p_order_id);
    END IF;
END$$
DELIMITER ;
