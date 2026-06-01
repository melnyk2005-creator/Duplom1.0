-- Average product rating (1-5) from review table.

DELIMITER $$
CREATE FUNCTION fn_product_avg_rating(p_product_id INT) RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(3,2) DEFAULT NULL;
    SELECT ROUND(AVG(rating), 2) INTO v_avg FROM review WHERE product_id = p_product_id AND deleted_dt IS NULL;
    RETURN COALESCE(v_avg, 0);
END$$
DELIMITER ;
