-- Create order_shipment (outbound: we send to customer). Optionally set warehouse and delivery method. Status = pending (1).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_shipment$$
CREATE PROCEDURE sp_create_shipment(
    IN p_order_id INT,
    IN p_warehouse_id INT,
    IN p_delivery_method_id INT,
    IN p_tracking_number VARCHAR(100),
    IN p_created_by BIGINT,
    OUT p_order_shipment_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_shipment: Create order shipment';

    INSERT INTO order_shipment (order_id, warehouse_id, delivery_method_id, tracking_number, shipment_status_id, created_by, modified_by)
    VALUES (p_order_id, p_warehouse_id, p_delivery_method_id, p_tracking_number, 1, p_created_by, p_created_by);
    SET p_order_shipment_id = LAST_INSERT_ID();
END$$
DELIMITER ;
