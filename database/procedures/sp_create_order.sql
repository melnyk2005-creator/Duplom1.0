-- Create order for user. Status = pending (1). Optionally set shipping address.
-- Optional p_order_items: JSON array of line items, e.g. [{"product_id":1,"product_sku_id":10,"quantity":2,"price":29.99}].

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_order$$
CREATE PROCEDURE sp_create_order(
    IN p_user_id BIGINT,
    IN p_shipping_address_id INT,
    IN p_created_by BIGINT,
    IN p_order_items JSON,
    OUT p_order_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_order: Create order';

    INSERT INTO `order` (user_id, total_amount, order_status_id, shipping_address_id, created_by, modified_by)
    VALUES (p_user_id, 0.00, 1, p_shipping_address_id, p_created_by, p_created_by);
    SET p_order_id = LAST_INSERT_ID();

    IF p_order_items IS NOT NULL AND JSON_LENGTH(p_order_items) > 0 THEN
        INSERT INTO order_item (order_id, product_id, product_sku_id, quantity, price, created_by, modified_by)
        SELECT
            p_order_id,
            j.product_id,
            NULLIF(j.product_sku_id, 0),
            GREATEST(1, COALESCE(j.quantity, 1)),
            j.price,
            p_created_by,
            p_created_by
        FROM JSON_TABLE(
            p_order_items,
            '$[*]' COLUMNS (
                product_id INT PATH '$.product_id',
                product_sku_id INT PATH '$.product_sku_id',
                quantity INT PATH '$.quantity',
                price DECIMAL(12, 2) PATH '$.price'
            )
        ) AS j;
        CALL sp_order_calculate_total(p_order_id);
    END IF;
END$$
DELIMITER ;
