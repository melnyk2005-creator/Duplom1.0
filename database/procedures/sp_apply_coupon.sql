-- Check and apply coupon; output discount amount and validity. Uses coupon_discount_type lookup.

DELIMITER $$
CREATE PROCEDURE sp_apply_coupon(
    IN p_coupon_code VARCHAR(50),
    IN p_order_amount DECIMAL(12,2),
    OUT p_discount DECIMAL(12,2),
    OUT p_valid TINYINT
)
proc_label: BEGIN
    DECLARE v_coupon_id INT;
    DECLARE v_discount_type_code VARCHAR(30);
    DECLARE v_discount_amt DECIMAL(12,2);
    DECLARE v_discount_pct DECIMAL(5,2);
    DECLARE v_max_uses INT;
    DECLARE v_used_count INT;
    DECLARE v_valid_from, v_valid_to TIMESTAMP;
    DECLARE v_min_order DECIMAL(12,2);

    SET p_discount = 0;
    SET p_valid = 0;

    SELECT coupon_id, dt.code, discount_amount, discount_percent, max_uses, used_count, valid_from, valid_to, min_order_amount
    INTO v_coupon_id, v_discount_type_code, v_discount_amt, v_discount_pct, v_max_uses, v_used_count, v_valid_from, v_valid_to, v_min_order
    FROM coupon c
    JOIN coupon_discount_type dt ON dt.coupon_discount_type_id = c.coupon_discount_type_id
    WHERE c.code = p_coupon_code AND c.deleted_dt IS NULL
    LIMIT 1;

    IF v_coupon_id IS NULL THEN
        LEAVE proc_label;
    END IF;
    IF (v_valid_from IS NOT NULL AND NOW() < v_valid_from) OR (v_valid_to IS NOT NULL AND NOW() > v_valid_to) THEN
        LEAVE proc_label;
    END IF;
    IF v_max_uses IS NOT NULL AND v_used_count >= v_max_uses THEN
        LEAVE proc_label;
    END IF;
    IF v_min_order IS NOT NULL AND p_order_amount < v_min_order THEN
        LEAVE proc_label;
    END IF;

    IF v_discount_type_code = 'amount' THEN
        SET p_discount = LEAST(COALESCE(v_discount_amt, 0), p_order_amount);
    ELSE
        SET p_discount = ROUND(p_order_amount * COALESCE(v_discount_pct, 0) / 100, 2);
    END IF;
    SET p_valid = 1;
END proc_label$$
DELIMITER ;
