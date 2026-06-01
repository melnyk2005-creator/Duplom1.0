-- Create purchase order (inbound: we order from supplier). Destination warehouse, optional delivery method. Status = draft (1).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_purchase_order$$
CREATE PROCEDURE sp_create_purchase_order(
    IN p_supplier_id INT,
    IN p_warehouse_id INT,
    IN p_delivery_method_id INT,
    IN p_order_date DATE,
    IN p_expected_delivery_date DATE,
    IN p_notes TEXT,
    IN p_created_by BIGINT,
    OUT p_purchase_order_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_purchase_order: Create purchase order';
    INSERT INTO purchase_order (supplier_id, warehouse_id, delivery_method_id, purchase_order_status_id, order_date, expected_delivery_date, notes, created_by, modified_by)
    VALUES (p_supplier_id, p_warehouse_id, p_delivery_method_id, 1, p_order_date, p_expected_delivery_date, p_notes, p_created_by, p_created_by);
    SET p_purchase_order_id = LAST_INSERT_ID();
END$$
DELIMITER ;
