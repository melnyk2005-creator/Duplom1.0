-- Add item to order_shipment (product + quantity). Does not change inventory; use sp_fulfill_shipment for that.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_shipment_add_item$$
CREATE PROCEDURE sp_shipment_add_item(
    IN p_order_shipment_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_created_by BIGINT,
    OUT p_order_shipment_item_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET p_quantity = GREATEST(1, p_quantity);
    SET @current_action_desc = 'sp_shipment_add_item: Add order shipment line item';

    INSERT INTO order_shipment_item (order_shipment_id, product_id, quantity, created_by, modified_by)
    VALUES (p_order_shipment_id, p_product_id, p_quantity, p_created_by, p_created_by);
    SET p_order_shipment_item_id = LAST_INSERT_ID();
END$$
DELIMITER ;
