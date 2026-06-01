-- Check if order can be fulfilled from warehouse (all order items have enough inventory by product_sku). OUT 1 = yes, 0 = no.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_can_fulfill_order$$
CREATE PROCEDURE sp_can_fulfill_order(
    IN p_order_id INT,
    IN p_warehouse_id INT,
    OUT p_can_fulfill TINYINT
)
BEGIN
    DECLARE v_missing INT DEFAULT 0;

    SET p_can_fulfill = 0;

    SELECT COUNT(*) INTO v_missing
    FROM order_item oi
    LEFT JOIN (
        SELECT product_sku_id, quantity
        FROM inventory
        WHERE warehouse_id = p_warehouse_id AND deleted_dt IS NULL
    ) inv ON inv.product_sku_id = oi.product_sku_id
    WHERE oi.order_id = p_order_id AND oi.deleted_dt IS NULL
      AND (oi.product_sku_id IS NULL OR COALESCE(inv.quantity, 0) < oi.quantity);

    IF v_missing = 0 THEN
        SET p_can_fulfill = 1;
    END IF;
END$$
DELIMITER ;
