-- Receive stock: add quantity for product_sku at warehouse. Insert or update inventory row.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_inventory_receive$$
CREATE PROCEDURE sp_inventory_receive(
    IN p_product_sku_id INT,
    IN p_warehouse_id INT,
    IN p_quantity INT,
    IN p_created_by BIGINT
)
BEGIN
    SET p_quantity = GREATEST(0, COALESCE(p_quantity, 0));
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_inventory_receive: Receive stock';

    INSERT INTO inventory (product_sku_id, warehouse_id, quantity, created_by, modified_by)
    VALUES (p_product_sku_id, p_warehouse_id, p_quantity, p_created_by, p_created_by)
    ON DUPLICATE KEY UPDATE
        quantity = quantity + p_quantity,
        modified_by = p_created_by,
        modified_dt = CURRENT_TIMESTAMP;
END$$
DELIMITER ;
