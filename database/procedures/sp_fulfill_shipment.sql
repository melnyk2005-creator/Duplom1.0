-- Fulfillment: allocate order items from warehouse to shipment.
-- Non-serialized SKU: decrease inventory, create shipment_item.
-- Serialized SKU: allocate product_units (FIFO = longest in warehouse first) via sp_allocate_units_to_order_item, then create shipment_item.
-- Customer gets any unit; we send the one that has been in stock longest.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_fulfill_shipment$$
CREATE PROCEDURE sp_fulfill_shipment(
    IN p_order_shipment_id INT,
    IN p_warehouse_id INT,
    IN p_created_by BIGINT,
    OUT p_ok TINYINT
)
proc_label: BEGIN
    DECLARE v_order_id INT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_oi_order_item_id INT;
    DECLARE v_oi_product_id INT;
    DECLARE v_oi_product_sku_id INT;
    DECLARE v_oi_quantity INT;
    DECLARE v_is_serialized TINYINT DEFAULT 0;
    DECLARE v_avail INT;
    DECLARE v_allocated INT;
    DECLARE cur CURSOR FOR
        SELECT oi.order_item_id, oi.product_id, oi.product_sku_id, oi.quantity
        FROM order_item oi
        JOIN order_shipment os ON os.order_id = oi.order_id
        WHERE os.order_shipment_id = p_order_shipment_id AND oi.deleted_dt IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    SET p_ok = 0;
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_fulfill_shipment: Fulfill order shipment from warehouse';

    SELECT order_id INTO v_order_id FROM order_shipment WHERE order_shipment_id = p_order_shipment_id AND deleted_dt IS NULL LIMIT 1;
    IF v_order_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fulfill_shipment: order_shipment not found';
    END IF;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_oi_order_item_id, v_oi_product_id, v_oi_product_sku_id, v_oi_quantity;
        IF v_done THEN LEAVE read_loop; END IF;

        IF v_oi_product_sku_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fulfill_shipment: order_item has no product_sku_id';
        END IF;

        SELECT COALESCE(ps.is_serialized, 0) INTO v_is_serialized
        FROM product_sku ps
        WHERE ps.product_sku_id = v_oi_product_sku_id AND ps.deleted_dt IS NULL
        LIMIT 1;

        IF v_is_serialized = 1 THEN
            SELECT COUNT(*) INTO v_avail
            FROM product_unit pu
            WHERE pu.product_sku_id = v_oi_product_sku_id AND pu.warehouse_id = p_warehouse_id
              AND pu.order_item_id IS NULL AND pu.deleted_dt IS NULL;
            IF v_avail < v_oi_quantity THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fulfill_shipment: insufficient serialized units for product_sku';
            END IF;
            CALL sp_allocate_units_to_order_item(v_oi_order_item_id, p_warehouse_id, p_created_by, v_allocated);
        ELSE
            SELECT quantity INTO v_avail
            FROM inventory
            WHERE product_sku_id = v_oi_product_sku_id AND warehouse_id = p_warehouse_id AND deleted_dt IS NULL
            LIMIT 1;
            SET v_avail = COALESCE(v_avail, 0);
            IF v_avail < v_oi_quantity THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fulfill_shipment: insufficient inventory for product_sku';
            END IF;
            UPDATE inventory
            SET quantity = quantity - v_oi_quantity, modified_by = p_created_by, modified_dt = CURRENT_TIMESTAMP
            WHERE product_sku_id = v_oi_product_sku_id AND warehouse_id = p_warehouse_id AND deleted_dt IS NULL;
        END IF;

        INSERT INTO order_shipment_item (order_shipment_id, product_id, quantity, created_by, modified_by)
        VALUES (p_order_shipment_id, v_oi_product_id, v_oi_quantity, p_created_by, p_created_by);
    END LOOP;
    CLOSE cur;

    UPDATE order_shipment
    SET warehouse_id = COALESCE(warehouse_id, p_warehouse_id), shipped_date = CURRENT_TIMESTAMP, shipment_status_id = 2, modified_by = p_created_by, modified_dt = CURRENT_TIMESTAMP
    WHERE order_shipment_id = p_order_shipment_id;
    SET p_ok = 1;
END proc_label$$
DELIMITER ;
