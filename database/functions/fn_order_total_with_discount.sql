-- Order total with discount applied (from coupon_redemption).

DELIMITER $$
CREATE FUNCTION fn_order_total_with_discount(p_order_id INT) RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(12,2) DEFAULT 0;
    DECLARE v_discount DECIMAL(12,2) DEFAULT 0;
    SELECT COALESCE(SUM(price * quantity), 0) INTO v_subtotal FROM order_item WHERE order_id = p_order_id AND deleted_dt IS NULL;
    SELECT COALESCE(SUM(discount_applied), 0) INTO v_discount FROM coupon_redemption WHERE order_id = p_order_id AND deleted_dt IS NULL;
    RETURN GREATEST(0, v_subtotal - v_discount);
END$$
DELIMITER ;
