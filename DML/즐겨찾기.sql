-- FV_01: 즐겨찾기 설정
DELIMITER //

CREATE PROCEDURE add_favorite(
    IN userIdInput BIGINT,
    IN favoritIdInput BIGINT
)
BEGIN
    INSERT INTO favorite (user_id, favorite_user_id)
    VALUES (userIdInput, favoritIdInput);
END //

DELIMITER ;

CALL add_favorite(3, 10);

-- FV_02: 즐겨찾기 해제
DELIMITER //

CREATE PROCEDURE delete_favorite(
    IN userIdInput BIGINT,
    IN favoritIdInput BIGINT
)
BEGIN
    DELETE FROM favorite
    WHERE user_id = userIdInput AND favorite_user_id = favoritIdInput;
END //

DELIMITER ;

CALL delete_favorite(3, 10);