-- Create payment for order. Default status = pending (1). After gateway confirms, call sp_payment_set_status(payment_id, 2).

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_payment$$
CREATE PROCEDURE sp_create_payment(
    IN p_order_id INT,
    IN p_amount DECIMAL(12,2),
    IN p_payment_method_id INT,
    IN p_external_id VARCHAR(100),
    IN p_created_by BIGINT,
    OUT p_payment_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_payment: Create payment';

    INSERT INTO payment (order_id, amount, payment_method_id, payment_status_id, external_id, created_by, modified_by)
    VALUES (p_order_id, p_amount, p_payment_method_id, 1, p_external_id, p_created_by, p_created_by);
    SET p_payment_id = LAST_INSERT_ID();
END$$
DELIMITER ;
