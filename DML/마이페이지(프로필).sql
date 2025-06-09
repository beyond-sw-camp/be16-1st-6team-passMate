-- MY_01: 사용자 정보 조회
DELIMITER //

CREATE PROCEDURE get_user_info(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM user WHERE user_id = p_user_id;
END //

DELIMITER ;

CALL get_user_info(1);

-- MY_02: 사용자 정보 수정
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

-- MY_03: 정산일 설정
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
        -- 없으면 삽입
        INSERT INTO settlement_setting(user_id, settlement_day)
        VALUES (userIdInput, settlementDayInput);
    END IF;
END //

DELIMITER ;

CALL setSettlementDay(1, 5);

-- MY_04 정산 조회
DELIMITER //

CREATE PROCEDURE get_settlement_info(IN userIdInput BIGINT)
BEGIN
    SELECT s.*
    FROM settlement s
    JOIN settlement_account sa ON s.settlement_account_id = sa.settlement_account_id
    WHERE sa.user_id = userIdInput;
END //

DELIMITER ;

-- MY_05: 정산 처리
DELIMITER //

CREATE PROCEDURE ProcessSettlements()
BEGIN
    UPDATE settlement s
    JOIN settlement_account sa ON s.settlement_account_id = sa.settlement_account_id
    JOIN settlement_setting ss ON sa.user_id = ss.user_id
    SET 
        s.is_completed = TRUE,
        s.settlement_date = NOW()
    WHERE s.is_completed = FALSE
      AND ss.settlement_day < DAY(CURDATE())
      AND (s.settlement_date IS NULL OR s.settlement_date < CURDATE());
END //

DELIMITER ;

