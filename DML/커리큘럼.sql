-- CUR_01: 커리큘럼 등록
DELIMITER //

CREATE PROCEDURE create_curriculum(
    IN p_user_id BIGINT,
    IN p_exam_subject_id BIGINT,
    IN p_name VARCHAR(255)
)
BEGIN
    DECLARE v_new_id BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '오류 발생' AS message, NULL AS curriculum_id;
    END;

    IF p_user_id IS NULL OR p_name IS NULL OR LTRIM(RTRIM(p_name)) = '' THEN
        SELECT '필수 값 누락' AS message, NULL AS curriculum_id;
    ELSE
        START TRANSACTION;

        INSERT INTO curriculum (user_id, exam_subject_id, name)
        VALUES (p_user_id, p_exam_subject_id, p_name);

        SET v_new_id = LAST_INSERT_ID();
        COMMIT;

		-- insert가 정상적으로 되었는지 확인
        SELECT * FROM curriculum WHERE curriculum_id = v_new_id;
    END IF;
END //

DELIMITER ;
CALL create_curriculum(1, 1, '데이터베이스 기초 커리큘럼');

-- CUR_02: 커리큘럼 수정
DELIMITER //

CREATE PROCEDURE update_curriculum(
    IN p_curriculum_id BIGINT,
    IN p_exam_subject_id BIGINT,
    IN p_name VARCHAR(255)
)
BEGIN
    UPDATE curriculum
    SET
        exam_subject_id = p_exam_subject_id,
        name = p_name
    WHERE curriculum_id = p_curriculum_id;

    SELECT * FROM curriculum WHERE curriculum_id = p_curriculum_id;
END //

DELIMITER ;
CALL update_curriculum(1, 1, '정보처리기사 실기 기초 커리큘럼');
-- CUR_03: 커리큘럼 삭제
DELIMITER //

CREATE PROCEDURE delete_curriculum(
    IN p_curriculum_id BIGINT
)
BEGIN
    DELETE FROM curriculum
    WHERE curriculum_id = p_curriculum_id;

    SELECT CONCAT('커리큘럼 ID ', p_curriculum_id, ' 삭제 완료') AS message;
END //

DELIMITER ;
CALL delete_curriculum(2);

-- CUR_04: 커리큘럼 조회
select * from curriculum where exam_subject_id = 1;