-- CART_01: 장바구니에 커리큘럼 추가
DELIMITER //

CREATE PROCEDURE add_cart(
    IN p_user_id BIGINT,
    IN p_curriculum_sale_id BIGINT
)
BEGIN
    DECLARE v_new_id BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '오류 발생' AS message, NULL AS cart_id;
    END;

    IF p_user_id IS NULL THEN
        SELECT '필수 값 누락' AS message, NULL AS cart_id;
    ELSE
        START TRANSACTION;

        INSERT INTO cart (user_id, curriculum_sale_id)
        VALUES (p_user_id, p_curriculum_sale_id);

        SET v_new_id = LAST_INSERT_ID();
        COMMIT;

		-- insert가 정상적으로 되었는지 확인
        SELECT * FROM cart WHERE cart_id = v_new_id;
    END IF;
END //

DELIMITER ;
CALL add_cart(1, 1);
-- CART_02: 커리큘럼 장바구니에서 삭제
DELIMITER //

CREATE PROCEDURE delete_cart(
    IN p_cart_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '오류 발생' AS message, NULL AS cart_id;
    END;

    IF p_cart_id IS NULL THEN
        SELECT '필수 값 누락' AS message, NULL AS cart_id;
    ELSE
        START TRANSACTION;
		
        DELETE FROM cart WHERE cart_id = p_cart_id;
        
        COMMIT;

	-- delete가 정상적으로 되었는지 확인
        SELECT * FROM cart WHERE cart_id = p_cart_id;
    END IF;
END //
CALL delete_cart(1);
