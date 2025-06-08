-- 사용자 정보 조회
DELIMITER //

CREATE PROCEDURE get_user_info(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM user WHERE user_id = p_user_id;
END //

DELIMITER ;

CALL get_user_info(1);

-- 사용자 정보 수정
DELIMITER //

CREATE PROCEDURE update_user_info(
    IN userIdInput BIGINT,
    IN emailInput VARCHAR(100),
    IN passwordInput VARCHAR(100),
    IN nicknameInput VARCHAR(20),
    IN imageInput VARCHAR(255),
    IN jobInput VARCHAR(255)
)
BEGIN
    UPDATE user
    SET email = emailInput,
        password = passwordInput,
        nickname = nicknameInput,
        profile_image = imageInput,
        job = jobInput,
        updated_at = NOw()
        
    WHERE user_id = userIdInput;
END //

DELIMITER ;

CALL update_user_info(1, "test@naver.com", "test1234", "test", "https://cdn.animaltoc.com/news/photo/202410/1409_6515_3838.jpg", "개발")

-- 즐겨찾기 설정
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

CALL update_user_info(3, 10);

-- 즐겨찾기 해제
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

-- 쪽지 보내기
DELIMITER //

CREATE PROCEDURE send_message(
    IN senderIdInput BIGINT,
    IN receiverIdInput BIGINT,
    IN contentsInput TEXT
)
BEGIN
    INSERT INTO message (sender_id, receiver_id, contents)
    VALUES (senderIdInput, receiverIdInput, contentsInput);
END //

DELIMITER ;

CALL send_message(1, 7, "쪽지 테스트 입니다.")

-- 쪽지 읽기
DELIMITER //

CREATE PROCEDURE read_message(IN messageIdInput BIGINT)
BEGIN
    UPDATE message
    SET is_read = TRUE
    WHERE message_id = messageIdInput;
END //

DELIMITER ;

CALL read_message(1);

-- 쪽지 새로고침
DELIMITER //

CREATE PROCEDURE refresh_messages(IN userIdInput BIGINT)
BEGIN
    SELECT * FROM message
    WHERE receiver_id = userIdInput
    ORDER BY created_at DESC
    LIMIT 10;
END //

CALL refresh_messages(1);

DELIMITER ;

-- 쪽지 삭제
DELIMITER //

CREATE PROCEDURE delete_message(IN messageIdInput BIGINT)
BEGIN
    DELETE FROM message WHERE message_id = messageIdInput;
END //

DELIMITER ;

CALL delete_message(1);

-- 정산 조회
DELIMITER //

CREATE PROCEDURE get_settlement_info(IN userIdInput BIGINT)
BEGIN
    SELECT s.*
    FROM settlement s
    JOIN settlement_account sa ON s.settlement_account_id = sa.settlement_account_id
    WHERE sa.user_id = userIdInput;
END //

DELIMITER ;

-- 정산 처리
DELIMITER //

CREATE PROCEDURE processSettlement()
BEGIN
    START TRANSACTION;

    UPDATE settlement s
    JOIN settlement_account sa ON s.settlement_account_id = sa.settlement_account_id
    JOIN settlement_setting ss ON sa.user_id = ss.user_id
    SET s.is_completed = true,
        s.settlement_date = NOW()
    WHERE s.is_completed = false
      AND ss.settlement_day IS NOT NULL
      AND DAY(CURDATE()) >= ss.settlement_day;

    COMMIT;
END;
//

DELIMITER ;

-- 정산일 설정
DELIMITER //

CREATE PROCEDURE setSettlementDay(
    IN userIdInput BIGINT,
    IN settlementDayInput TINYINT
)
BEGIN
    DECLARE settingExists INT;

    -- 이미 설정이 있는지 확인
    SELECT COUNT(*) INTO settingExists
    FROM settlement_setting
    WHERE user_id = userIdInput;

    IF settingExists > 0 THEN
        -- 있으면 업데이트
        UPDATE settlement_setting
        SET settlement_day = settlementDayInput,
            updated_at = NOW()
        WHERE user_id = userIdInput;
    ELSE
        -- 없으면 새로 삽입
        INSERT INTO settlement_setting(user_id, settlement_day)
        VALUES (userIdInput, settlementDayInput);
    END IF;
END //

DELIMITER ;

CALL setSettlementDay(1, 5);