-- Adjust stock: add (positive) or subtract (negative) quantity for product_sku at warehouse. Fails if result < 0.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_inventory_adjust$$
CREATE PROCEDURE sp_inventory_adjust(
    IN p_product_sku_id INT,
    IN p_warehouse_id INT,
    IN p_delta INT,
    IN p_created_by BIGINT,
    OUT p_ok TINYINT
)
proc_label: BEGIN
    DECLARE v_current INT DEFAULT 0;
    DECLARE v_new_qty INT;

    SET p_ok = 0;
    SET p_created_by = COALESCE(p_created_by, 0);

    SELECT quantity INTO v_current
    FROM inventory
    WHERE product_sku_id = p_product_sku_id AND warehouse_id = p_warehouse_id AND deleted_dt IS NULL
    LIMIT 1;

    IF v_current IS NULL THEN
        IF p_delta < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'inventory_adjust: no row to decrease';
        END IF;
        SET @current_action_desc = 'sp_inventory_adjust: Insert new inventory row';
        INSERT INTO inventory (product_sku_id, warehouse_id, quantity, created_by, modified_by)
        VALUES (p_product_sku_id, p_warehouse_id, GREATEST(0, p_delta), p_created_by, p_created_by);
        SET p_ok = 1;
        LEAVE proc_label;
    END IF;

    SET v_new_qty = v_current + p_delta;
    IF v_new_qty < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'inventory_adjust: insufficient quantity';
    END IF;
    SET @current_action_desc = 'sp_inventory_adjust: Adjust quantity';

    UPDATE inventory
    SET quantity = v_new_qty, modified_by = p_created_by, modified_dt = CURRENT_TIMESTAMP
    WHERE product_sku_id = p_product_sku_id AND warehouse_id = p_warehouse_id AND deleted_dt IS NULL;
    SET p_ok = 1;
END proc_label$$
DELIMITER ;
