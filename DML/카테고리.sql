-- CT_01: 카테고리 조회
select j.name as '직무', c.name as '자격증' from category as c
left join job_field as j on c.job_field_id = j.job_field_id
where j.name = '정보기술';

-- CT_02: 카테고리 생성
DELIMITER //

CREATE PROCEDURE insert_category (
    IN p_qualification_name VARCHAR(255),
    IN p_job_field_name VARCHAR(255),
    IN p_category_name VARCHAR(255)
)
BEGIN
    DECLARE v_qualification_type_id BIGINT;
    DECLARE v_job_field_id BIGINT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오류 발생: 트랜잭션을 롤백했습니다.';
    END;

    -- 입력값 검사: NOT NULL 제약 조건 위반 방지
    IF p_qualification_name IS NULL OR LTRIM(RTRIM(p_qualification_name)) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '자격구분 이름이 누락되었습니다.';
    END IF;

    IF p_job_field_name IS NULL OR LTRIM(RTRIM(p_job_field_name)) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '직무분야 이름이 누락되었습니다.';
    END IF;

    IF p_category_name IS NULL OR LTRIM(RTRIM(p_category_name)) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '카테고리 이름이 누락되었습니다.';
    END IF;

    START TRANSACTION;

    -- 1. 자격구분 중복 확인 및 삽입
    SELECT qualification_type_id INTO v_qualification_type_id
    FROM qualification_type
    WHERE name = p_qualification_name
    LIMIT 1;

    IF v_qualification_type_id IS NULL THEN
        INSERT INTO qualification_type (name)
        VALUES (p_qualification_name);
        SET v_qualification_type_id = LAST_INSERT_ID();
    END IF;

    -- 2. 직무분야 중복 확인 및 삽입
    SELECT job_field_id INTO v_job_field_id
    FROM job_field
    WHERE name = p_job_field_name
      AND qualification_type_id = v_qualification_type_id
    LIMIT 1;

    IF v_job_field_id IS NULL THEN
        INSERT INTO job_field (qualification_type_id, name)
        VALUES (v_qualification_type_id, p_job_field_name);
        SET v_job_field_id = LAST_INSERT_ID();
    END IF;

    -- 3. 분류 중복 확인 및 삽입
    IF NOT EXISTS (
        SELECT 1 FROM category
        WHERE name = p_category_name AND job_field_id = v_job_field_id
    ) THEN
        INSERT INTO category (job_field_id, name)
        VALUES (v_job_field_id, p_category_name);
    END IF;

    COMMIT;
    
    -- 4. insert 여부 확인
    SELECT * FROM category WHERE category_id = LAST_INSERT_ID();
END //
CALL insert_category('국가기술자격', '정보기술', '정보처리기능사');
CALL insert_category('국가기술자격', '정보기술', '정보처리기사');
DELIMITER ;
-- CT_03: 카테고리 수정
DELIMITER //

CREATE PROCEDURE update_category (
    IN p_category_id BIGINT,
    IN p_job_field_id BIGINT,
    IN p_name VARCHAR(255)
)
BEGIN
    DECLARE v_count INT;

    -- 예외 발생 시 롤백 및 메시지
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '카테고리 수정 중 예외가 발생했습니다. 롤백되었습니다.';
    END;

    START TRANSACTION;

    -- 1. 수정 대상 카테고리 존재 여부 확인
    SELECT COUNT(*) INTO v_count
    FROM category
    WHERE category_id = p_category_id;

    IF v_count = 0 THEN
        -- 카테고리가 없으면 롤백 후 SIGNAL
        ROLLBACK;
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = '해당 category_id가 존재하지 않습니다.';
    END IF;

    -- 2. 동일 job_field_id 내 중복 name 체크 (본인 제외)
    SELECT COUNT(*) INTO v_count
    FROM category
    WHERE job_field_id = p_job_field_id
      AND name = p_name
      AND category_id != p_category_id;

    IF v_count > 0 THEN
        -- 중복이 있으면 롤백 후 SIGNAL
        ROLLBACK;
        SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = '해당 직무분야 내에서 동일한 분류명이 이미 존재합니다.';
    END IF;

    -- 3. 업데이트 수행
    UPDATE category
    SET job_field_id = p_job_field_id,
        name = p_name
    WHERE category_id = p_category_id;

    COMMIT;
    
    -- 4. update 여부 조회
    SELECT * FROM category WHERE category_id = p_category_id;
END //

DELIMITER ;

-- CT_04: 카테고리 삭제
DELIMITER //

CREATE PROCEDURE delete_category (
    IN p_category_id BIGINT
)
BEGIN
    DECLARE v_count INT;

    -- 예외 발생 시 롤백 및 사용자 정의 메시지 처리
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '카테고리 삭제 중 예외가 발생했습니다. 롤백되었습니다.';
    END;

    START TRANSACTION;

    -- 삭제할 카테고리 존재 여부 확인
    SELECT COUNT(*) INTO v_count
    FROM category
    WHERE category_id = p_category_id;

    IF v_count = 0 THEN
        -- 존재하지 않으면 롤백 후 SIGNAL
        ROLLBACK;
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = '해당 category_id가 존재하지 않아 삭제할 수 없습니다.';
    END IF;

    -- 삭제 실행
    DELETE FROM category
    WHERE category_id = p_category_id;

    COMMIT;
    
    -- 삭제되었는지 전체 조회를 통해 확인
    select * from category;
END //

DELIMITER ;
CALL delete_category(2);