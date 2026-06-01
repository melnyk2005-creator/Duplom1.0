-- Mark purchase order as received and receive all line items to warehouse (calls sp_inventory_receive per line).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_receive_purchase_order$$
CREATE PROCEDURE sp_receive_purchase_order(
    IN p_purchase_order_id INT,
    IN p_created_by BIGINT,
    OUT p_ok TINYINT
)
proc_label:
BEGIN
    DECLARE v_warehouse_id INT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_product_sku_id INT;
    DECLARE v_quantity INT;
    DECLARE cur CURSOR FOR
        SELECT poi.product_sku_id, poi.quantity
        FROM purchase_order_item poi
        WHERE poi.purchase_order_id = p_purchase_order_id
          AND poi.deleted_dt IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    SET p_ok = 0;
    SET p_created_by = COALESCE(p_created_by, 0);

    SELECT warehouse_id
    INTO v_warehouse_id
    FROM purchase_order
    WHERE purchase_order_id = p_purchase_order_id
      AND deleted_dt IS NULL
    LIMIT 1;
    IF v_warehouse_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'sp_receive_purchase_order: purchase order not found';
    END IF;

    SET @current_action_desc = 'sp_receive_purchase_order: Receive purchase order to warehouse';
    OPEN cur;
    read_loop:
    LOOP
        FETCH cur INTO v_product_sku_id, v_quantity;
        IF v_done THEN LEAVE read_loop; END IF;
        CALL sp_inventory_receive(v_product_sku_id, v_warehouse_id, v_quantity, p_created_by);
    END LOOP;
    CLOSE cur;

    UPDATE purchase_order
    SET purchase_order_status_id = 4,
        modified_by              = p_created_by,
        modified_dt              = CURRENT_TIMESTAMP
    WHERE purchase_order_id = p_purchase_order_id;
    SET p_ok = 1;
END proc_label$$
DELIMITER ;
