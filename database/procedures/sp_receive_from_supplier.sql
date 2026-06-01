-- Receive stock from supplier: multiple product_sku + quantity in one call. Uses sp_inventory_receive per line.
-- p_items: JSON array e.g. [{"product_sku_id": 1, "quantity": 100}, {"product_sku_id": 2, "quantity": 50}].

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_receive_from_supplier$$
CREATE PROCEDURE sp_receive_from_supplier(
    IN p_warehouse_id INT,
    IN p_items JSON,
    IN p_created_by BIGINT,
    OUT p_ok TINYINT
)
BEGIN
    SET p_ok = 0;
    SET p_created_by = COALESCE(p_created_by, 0);

    IF p_items IS NULL OR JSON_LENGTH(p_items) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'sp_receive_from_supplier: items required';
    END IF;
    SET @current_action_desc = 'sp_receive_from_supplier: Receive stock from supplier';

    INSERT INTO inventory (product_sku_id, warehouse_id, quantity, created_by, modified_by)
    SELECT j.product_sku_id,
           p_warehouse_id,
           GREATEST(0, COALESCE(j.quantity, 0)),
           p_created_by,
           p_created_by
    FROM JSON_TABLE(
                 p_items,
                 '$[*]' COLUMNS (
                     product_sku_id INT PATH '$.product_sku_id',
                     quantity INT PATH '$.quantity'
                     )
         ) AS j
    WHERE j.product_sku_id IS NOT NULL
      AND j.quantity > 0
    ON DUPLICATE KEY UPDATE quantity    = inventory.quantity + VALUES(quantity),
                            modified_by = VALUES(modified_by),
                            modified_dt = CURRENT_TIMESTAMP;

    SET p_ok = 1;
END$$
DELIMITER ;
