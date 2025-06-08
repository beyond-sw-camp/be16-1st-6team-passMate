-- 유저 생성 프로시저저

DELIMITER //

CREATE PROCEDURE insert_users()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 20 DO
        INSERT INTO user (
            email,
            nickname,
            password,
            role,
            profile_image,
            job
        )
        VALUES (
            CONCAT('user', i, '@naver.com'),
            CONCAT('user', i),
            'encrypted_password',
            'USER',
            NULL,
            NULL
        );
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;


-- 쪽지 보내기 프로시저
DELIMITER //

CREATE PROCEDURE insert_messages()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE sender_id INT;
    DECLARE receiver_id INT;

    WHILE i <= 10 DO
        SET sender_id = FLOOR(1 + (RAND() * 20));
        SET receiver_id = FLOOR(1 + (RAND() * 20));

        -- 자기 자신에게는 쪽지를 보낼 수 X
        IF sender_id != receiver_id THEN
            INSERT INTO message (sender_id, receiver_id, contents)
            VALUES (
                sender_id,
                receiver_id,
                CONCAT('쪽지test 번호: ', i)
            );
            SET i = i + 1;
        END IF;
    END WHILE;
END //

DELIMITER ;

-- 좋아요 생성 프로시저
DELIMITER //

CREATE PROCEDURE insert_favorites()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE userId BIGINT;
    DECLARE favoriteUserId BIGINT;

    WHILE i <= 10 DO
        -- user_id와 favorite_user_id가 같지 않도록 설정
        SET userId = FLOOR(1 + RAND() * 20);
        SET favoriteUserId = FLOOR(1 + RAND() * 20);

        WHILE favoriteUserId = userId DO
            SET favoriteUserId = FLOOR(1 + RAND() * 20);
        END WHILE;

        INSERT INTO favorite (user_id, favorite_user_id)
        VALUES (userId, favoriteUserId);

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- 정산 계좌
INSERT INTO settlement_account(user_id, bank, account_number) VALUES
(1, '국민', '1234567890123456781'),
(2, '기업', '2234567890123456782'),
(3, '우리', '3234567890123456783'),
(4, '하나', '4234567890123456784'),
(5, '농협', '5234567890123456785'),
(6, '신한', '6234567890123456786'),
(7, '카카오', '7234567890123456787'),
(8, '기업업', '8234567890123456788'),
(9, '케이뱅크', '9234567890123456789'),
(10, '토스', '1034567890123456780');

-- 정산 내역
INSERT INTO settlement (settlement_account_id, payment_id, settlement_amount, settlement_date, is_completed) VALUES
(5, 8, 75000, NOW(), true),
(3, 6, 54000, NOW(), true),
(2, 4, 62000, NOW(), true),
(7, 3, 81000, NOW(), true),
(6, 2, 90500, NOW(), true),
(4, 5, 45000, NOW(), true),
(1, 9, 99000, NOW(), true),
(8, 7, 37000, NOW(), false),
(9, 1, 66000, NOW(), false),
(10, 10, 72000, NOW(), false);

-- 결제 내역
INSERT INTO payment (user_id, curriculum_sale_id, method_id, status, date, confirm) VALUES
(1, 1, 1, 'STANBY', NOW(), false),
(2, 3, 2, 'IN_PROGRESS', NOW(), true),
(3, 2, 3, 'COMPLETE', NOW(), true),
(4, 4, 4, 'STANBY', NOW(), false),
(5, 5, 5, 'IN_PROGRESS', NOW(), false),
(6, 6, 6, 'COMPLETE', NOW(), true),
(7, 7, 7, 'STANBY', NOW(), false),
(8, 8, 8, 'IN_PROGRESS', NOW(), true),
(9, 9, 9, 'COMPLETE', NOW(), true),
(10, 10, 10, 'STANBY', NOW(), false);

-- 알림 내역
INSERT INTO notification (user_id, content, is_seen, created_at) VALUES
(3, '알림테스트 입니다.', false, NOW()),
(7, '알림테스트 입니다.', false, NOW()),
(12, '알림테스트 입니다.', true, NOW()),
(5, '알림테스트 입니다.', false, NOW()),
(18, '알림테스트 입니다.', false, NOW()),
(3, '알림테스트 입니다.', true, NOW()),
(15, '알림테스트 입니다.', false, NOW()),
(20, '알림테스트 입니다.', true, NOW()),
(1, '알림테스트 입니다.', false, NOW()),
(10, '알림테스트 입니다.', true, NOW());

-- 알림 내역 프로시저
DELIMITER //

CREATE PROCEDURE insert_notifications()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE rand_user_id INT;

  WHILE i <= 10 DO
    SET rand_user_id = FLOOR(1 + RAND() * 20);

    INSERT INTO notification (
      user_id, content, is_seen, created_at
    ) VALUES (
      rand_user_id,
      CONCAT('알림 테스트 입니다. ', rand_user_id),
      FALSE,
      NOW()
    );

    SET i = i + 1;
  END WHILE;
END //

DELIMITER ;