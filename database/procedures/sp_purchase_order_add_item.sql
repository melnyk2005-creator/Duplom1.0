DELIMITER $$
DROP PROCEDURE IF EXISTS sp_purchase_order_add_item$$
CREATE PROCEDURE sp_purchase_order_add_item(
    IN p_purchase_order_id INT,
    IN p_product_sku_id INT,
    IN p_quantity INT,
    IN p_unit_cost DECIMAL(12, 2),
    IN p_created_by BIGINT,
    OUT p_purchase_order_item_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET p_quantity = GREATEST(1, p_quantity);
    SET @current_action_desc = 'sp_purchase_order_add_item: Add purchase order line item';
    INSERT INTO purchase_order_item (purchase_order_id, product_sku_id, quantity, unit_cost, created_by, modified_by)
    VALUES (p_purchase_order_id, p_product_sku_id, p_quantity, p_unit_cost, p_created_by, p_created_by);
    SET p_purchase_order_item_id = LAST_INSERT_ID();
END$$
DELIMITER ;
