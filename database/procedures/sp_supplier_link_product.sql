-- Link product to supplier (with optional supplier_sku and cost_price). For admin: which products we buy from this supplier.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_supplier_link_product$$
CREATE PROCEDURE sp_supplier_link_product(
    IN p_supplier_id INT,
    IN p_product_id INT,
    IN p_supplier_sku VARCHAR(100),
    IN p_cost_price DECIMAL(12, 2),
    IN p_created_by BIGINT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_supplier_link_product: Link supplier to product';

    INSERT INTO supplier_product (supplier_id, product_id, supplier_sku, cost_price, created_by, modified_by)
    VALUES (p_supplier_id, p_product_id, p_supplier_sku, p_cost_price, p_created_by, p_created_by)
    ON DUPLICATE KEY UPDATE supplier_sku = COALESCE(VALUES(supplier_sku), supplier_sku),
                            cost_price   = COALESCE(VALUES(cost_price), cost_price),
                            modified_by  = p_created_by,
                            modified_dt  = CURRENT_TIMESTAMP;
END$$
DELIMITER ;
