-- Create product_sku (variant with price). Quantity is only in inventory.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_product_sku$$
CREATE PROCEDURE sp_create_product_sku(
    IN p_product_id INT,
    IN p_sku VARCHAR(50),
    IN p_price DECIMAL(12,2),
    IN p_size_attribute_id INT,
    IN p_color_attribute_id INT,
    IN p_is_serialized TINYINT,
    IN p_created_by BIGINT,
    OUT p_product_sku_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET p_is_serialized = COALESCE(p_is_serialized, 0);
    SET @current_action_desc = 'sp_create_product_sku: Create product SKU';

    INSERT INTO product_sku (
        product_id, sku, size_attribute_id, color_attribute_id, price, is_serialized, created_by, modified_by
    ) VALUES (
        p_product_id, p_sku, p_size_attribute_id, p_color_attribute_id, p_price, p_is_serialized, p_created_by, p_created_by
    );
    SET p_product_sku_id = LAST_INSERT_ID();
END$$
DELIMITER ;
