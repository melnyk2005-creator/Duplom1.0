-- Create product attribute (e.g. size=M, color=Red). Used by product_sku via size_attribute_id, color_attribute_id.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_product_attribute$$
CREATE PROCEDURE sp_create_product_attribute(
    IN p_attribute_type VARCHAR(50),
    IN p_attribute_value VARCHAR(100),
    IN p_created_by BIGINT,
    OUT p_product_attribute_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_product_attribute: Create product attribute';

    INSERT INTO product_attribute (attribute_type, attribute_value, created_by, modified_by)
    VALUES (p_attribute_type, p_attribute_value, p_created_by, p_created_by);
    SET p_product_attribute_id = LAST_INSERT_ID();
END$$
DELIMITER ;
