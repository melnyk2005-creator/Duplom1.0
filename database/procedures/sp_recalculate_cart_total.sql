-- Recalculate cart total by cart_id. Price taken from product_sku.

DELIMITER $$
CREATE PROCEDURE sp_recalculate_cart_total(IN p_cart_id INT)
BEGIN
    SET @current_action_desc = 'sp_recalculate_cart_total: Recalculate cart total';
    UPDATE cart c
    SET c.total = (SELECT COALESCE(SUM(COALESCE(ps.price, 0) * ci.quantity), 0)
                   FROM cart_item ci
                            LEFT JOIN product_sku ps
                                      ON ps.product_sku_id = ci.product_sku_id AND ps.product_id = ci.product_id
                   WHERE ci.cart_id = p_cart_id)
    WHERE c.cart_id = p_cart_id;
END$$
DELIMITER ;
