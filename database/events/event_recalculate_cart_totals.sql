-- Event: daily recalc of cart totals (run in main schema). Price from product_sku.

DELIMITER //

DROP EVENT IF EXISTS event_recalculate_cart_totals//
CREATE EVENT event_recalculate_cart_totals
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE cart c
    SET c.total = (
        SELECT COALESCE(SUM(COALESCE(ps.price, 0) * ci.quantity), 0)
        FROM cart_item ci
        LEFT JOIN product_sku ps ON ps.product_sku_id = ci.product_sku_id AND ps.product_id = ci.product_id
        WHERE ci.cart_id = c.cart_id AND ci.deleted_dt IS NULL
    );
END//

DELIMITER ;
