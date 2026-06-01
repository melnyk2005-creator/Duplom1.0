-- Get total available quantity for a product_sku (sum across all warehouses). Optional: single warehouse.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_available_quantity$$
CREATE PROCEDURE sp_get_available_quantity(
    IN p_product_sku_id INT,
    IN p_warehouse_id INT,
    OUT p_quantity INT
)
BEGIN
    IF p_warehouse_id IS NULL THEN
        SELECT COALESCE(SUM(quantity), 0) INTO p_quantity
        FROM inventory
        WHERE product_sku_id = p_product_sku_id AND deleted_dt IS NULL;
    ELSE
        SELECT COALESCE(quantity, 0) INTO p_quantity
        FROM inventory
        WHERE product_sku_id = p_product_sku_id AND warehouse_id = p_warehouse_id AND deleted_dt IS NULL
        LIMIT 1;
        SET p_quantity = COALESCE(p_quantity, 0);
    END IF;
END$$
DELIMITER ;
