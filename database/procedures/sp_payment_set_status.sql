-- Set payment status (1=pending, 2=completed, 3=failed, 4=refunded). Optionally set order to paid when completed.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_payment_set_status$$
CREATE PROCEDURE sp_payment_set_status(
    IN p_payment_id INT,
    IN p_payment_status_id INT,
    IN p_modified_by BIGINT,
    IN p_set_order_paid TINYINT
)
BEGIN
    DECLARE v_order_id INT;

    SET p_modified_by = COALESCE(p_modified_by, 0);
    SET p_set_order_paid = COALESCE(p_set_order_paid, 0);
    SET @current_action_desc = 'sp_payment_set_status: Set payment status';

    UPDATE payment
    SET payment_status_id = p_payment_status_id,
        modified_by       = p_modified_by,
        modified_dt       = CURRENT_TIMESTAMP
    WHERE payment_id = p_payment_id
      AND deleted_dt IS NULL;

    IF p_set_order_paid = 1 AND p_payment_status_id = 2 THEN
        SELECT order_id INTO v_order_id FROM payment WHERE payment_id = p_payment_id LIMIT 1;
        IF v_order_id IS NOT NULL THEN
            SET @current_action_desc = 'sp_payment_set_status: Set order paid';
            UPDATE `order`
            SET order_status_id = 2,
                modified_by     = p_modified_by,
                modified_dt     = CURRENT_TIMESTAMP
            WHERE order_id = v_order_id
              AND deleted_dt IS NULL;
        END IF;
    END IF;
END$$
DELIMITER ;
