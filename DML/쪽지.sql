-- MS_01: 쪽지 보내기
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

-- MS_02: 쪽지 읽기
DELIMITER //

CREATE PROCEDURE read_message(IN messageIdInput BIGINT)
BEGIN
    UPDATE message
    SET is_seen = TRUE
    WHERE message_id = messageIdInput;
END //

DELIMITER ;

CALL read_message(1);

-- MS_03: 쪽지 새로고침
DELIMITER //

CREATE PROCEDURE refresh_messages(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM message
    WHERE receiver_id = p_user_id
    ORDER BY created_at DESC
END //

DELIMITER ;

-- MS_04: 쪽지 삭제
DELIMITER //

CREATE PROCEDURE delete_message(IN messageIdInput BIGINT)
BEGIN
    DELETE FROM message WHERE message_id = messageIdInput;
END //

DELIMITER ;

CALL delete_message(1);