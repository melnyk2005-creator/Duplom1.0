-- Create supplier.

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_supplier$$
CREATE PROCEDURE sp_create_supplier(
    IN p_name VARCHAR(200),
    IN p_contact_info VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(50),
    IN p_created_by BIGINT,
    OUT p_supplier_id INT
)
BEGIN
    SET p_created_by = COALESCE(p_created_by, 0);
    SET @current_action_desc = 'sp_create_supplier: Create supplier';

    INSERT INTO supplier (name, contact_info, email, phone, created_by, modified_by)
    VALUES (p_name, p_contact_info, p_email, p_phone, p_created_by, p_created_by);
    SET p_supplier_id = LAST_INSERT_ID();
END$$
DELIMITER ;
