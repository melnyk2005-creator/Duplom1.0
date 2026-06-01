-- Create product. Optionally link category, sub_category, brand.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_product$$
CREATE PROCEDURE sp_create_product(
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    IN p_short_description VARCHAR(500),
    IN p_category_id INT,
    IN p_sub_category_id INT,
    IN p_brand_id INT,
    IN p_weight_kg DECIMAL(10,3),
    IN p_is_featured TINYINT,
    IN p_created_by BIGINT,
    OUT p_product_id INT
)
BEGIN
    SET p_is_featured = COALESCE(p_is_featured, 0);
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_product: Create product';

    INSERT INTO product (
        name, description, short_description, category_id, sub_category_id, brand_id,
        stock_quantity, weight_kg, is_featured, created_by, modified_by
    ) VALUES (
        p_name, p_description, p_short_description, p_category_id, p_sub_category_id, p_brand_id,
        0, p_weight_kg, p_is_featured, p_created_by, p_created_by
    );
    SET p_product_id = LAST_INSERT_ID();
END$$
DELIMITER ;
