-- Allocate available serialized units to an order line. Sets order_item_id on product_unit rows.
-- FIFO: picks units that have been in warehouse longest (ORDER BY created_dt, product_unit_id).
-- OUT p_allocated = number of units allocated. Fails if not enough available units.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_allocate_units_to_order_item$$
CREATE PROCEDURE sp_allocate_units_to_order_item(
    IN p_order_item_id INT,
    IN p_warehouse_id INT,
    IN p_modified_by BIGINT,
    OUT p_allocated INT
)
BEGIN
    DECLARE v_product_sku_id INT;
    DECLARE v_quantity INT;
    DECLARE v_available INT;

    SET p_allocated = 0;
    SET p_modified_by = COALESCE(p_modified_by, 0);

    SELECT oi.product_sku_id, oi.quantity
    INTO v_product_sku_id, v_quantity
    FROM order_item oi
    WHERE oi.order_item_id = p_order_item_id AND oi.deleted_dt IS NULL
    LIMIT 1;

    IF v_product_sku_id IS NULL OR v_quantity IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'sp_allocate_units_to_order_item: order_item not found';
    END IF;

    SELECT COUNT(*) INTO v_available
    FROM product_unit pu
    WHERE pu.product_sku_id = v_product_sku_id AND pu.warehouse_id = p_warehouse_id
      AND pu.order_item_id IS NULL AND pu.deleted_dt IS NULL;

    IF v_available < v_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'sp_allocate_units_to_order_item: insufficient serialized units';
    END IF;

    SET @current_action_desc = 'sp_allocate_units_to_order_item: Allocate units to order line';
    UPDATE product_unit
    SET order_item_id = p_order_item_id, modified_by = p_modified_by, modified_dt = CURRENT_TIMESTAMP
    WHERE product_sku_id = v_product_sku_id AND warehouse_id = p_warehouse_id
      AND order_item_id IS NULL AND deleted_dt IS NULL
    ORDER BY created_dt ASC, product_unit_id ASC
    LIMIT v_quantity;

    SET p_allocated = ROW_COUNT();
END$$
DELIMITER ;
