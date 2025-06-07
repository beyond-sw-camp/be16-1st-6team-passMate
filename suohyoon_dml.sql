/* 카테고리 */
-- 카테고리 조회
DELIMITER //

CREATE PROCEDURE get_exam_subjects_by_category (
    IN p_category_id BIGINT
)
BEGIN
    SELECT * FROM exam_subject
    WHERE category_id = p_category_id;
END //

DELIMITER ;
-- 카테고리 생성
/*
1. 자격구분 데이터 insert
2. 직무분야 데이터 insert
3. 분류 데이터 insert
*/
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
END //

DELIMITER ;
-- 카테고리 수정
DELIMITER //

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
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '카테고리 수정 중 예외가 발생했습니다. 롤백되었습니다.';
    END;

    START TRANSACTION;

    -- 1. 수정 대상 카테고리 존재 여부 확인
    SELECT COUNT(*) INTO v_count
    FROM category
    WHERE category_id = p_category_id;

    IF v_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = '해당 category_id가 존재하지 않습니다.';
    END IF;

    -- 2. 동일 job_field_id 내 중복 name 체크 (본인 제외)
    SELECT COUNT(*) INTO v_count
    FROM category
    WHERE job_field_id = p_job_field_id
      AND name = p_name
      AND category_id != p_category_id;

    IF v_count > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = '해당 직무분야 내에서 동일한 분류명이 이미 존재합니다.';
    END IF;

    -- 3. 업데이트 수행
    UPDATE category
    SET job_field_id = p_job_field_id,
        name = p_name
    WHERE category_id = p_category_id;

    COMMIT;
END //

DELIMITER ;
-- 카테고리 삭제
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
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '카테고리 삭제 중 예외가 발생했습니다. 롤백되었습니다.';
    END;

    START TRANSACTION;

    -- 삭제할 카테고리 존재 여부 확인
    SELECT COUNT(*) INTO v_count
    FROM category
    WHERE category_id = p_category_id;

    IF v_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = '해당 category_id가 존재하지 않아 삭제할 수 없습니다.';
    END IF;

    -- 삭제 실행
    DELETE FROM category
    WHERE category_id = p_category_id;

    COMMIT;
END //

DELIMITER ;

/* 자격증 */
-- 자격증 상세 정보 조회
DELIMITER //

CREATE PROCEDURE select_exam_detail(
    IN p_exam_subject_id BIGINT
)
BEGIN
    SELECT
        es.exam_subject_id,
        es.category_id,
        c.name AS category_name,
        es.organization_id,
        o.name AS organization_name,
        es.name,
        es.description,
        es.add_info
    FROM
        exam_subject es
    LEFT JOIN
        category c ON es.category_id = c.category_id
    LEFT JOIN
        organization o ON es.organization_id = o.organization_id
    WHERE
        es.exam_subject_id = p_exam_subject_id;
END //

DELIMITER ;
-- 자격증 상세 정보 생성
DELIMITER //

CREATE PROCEDURE create_exam_detail(
    IN p_category_id BIGINT,
    IN p_organization_id BIGINT,
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    IN p_add_info VARCHAR(255),
    OUT p_status INT,           -- 0: 성공, -1: 필수 값 누락, -2: FK 오류, -3: 기타 오류
    OUT p_new_exam_subject_id BIGINT
)
BEGIN
    -- 에러 핸들러 선언: 특정 오류 발생 시 동작 정의
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 오류 발생 시 트랜잭션 롤백
        ROLLBACK;
        -- 외래 키 제약 조건 위반 오류 코드 (MariaDB/MySQL)
        IF SQLSTATE = '23000' THEN -- Integrity constraint violation
            SET p_status = -2; -- FK 오류 또는 NOT NULL 제약 조건 위반 등
        ELSE
            SET p_status = -3; -- 기타 오류
        END IF;
        SET p_new_exam_subject_id = NULL; -- 새 ID는 없음
    END;

    -- 필수 값 (name) 검사
    IF p_name IS NULL OR LTRIM(RTRIM(p_name)) = '' THEN
        SET p_status = -1;
        SET p_new_exam_subject_id = NULL;
    ELSE
        START TRANSACTION; -- 트랜잭션 시작

        INSERT INTO exam_subject (category_id, organization_id, name, description, add_info)
        VALUES (p_category_id, p_organization_id, p_name, p_description, p_add_info);

        SET p_new_exam_subject_id = LAST_INSERT_ID(); -- 새로 삽입된 ID 가져오기
        SET p_status = 0; -- 성공

        COMMIT; -- 트랜잭션 커밋
    END IF;
END //

DELIMITER ;
-- 자격증 상세 정보 수정
DELIMITER //

CREATE PROCEDURE update_exam_detail(
    IN p_exam_subject_id BIGINT,
    IN p_category_id BIGINT,
    IN p_organization_id BIGINT,
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    IN p_add_info VARCHAR(255),
    OUT p_status INT             -- 0: 성공, -1: ID 찾을 수 없음, -2: name NULL 오류, -3: FK 오류, -4: 기타 오류
)
BEGIN
    -- 에러 핸들러 선언
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        IF SQLSTATE = '23000' THEN
            SET p_status = -3; -- FK 오류 또는 NOT NULL 제약 조건 위반 등
        ELSE
            SET p_status = -4; -- 기타 오류
        END IF;
    END;

    -- 존재하지 않는 ID에 대한 업데이트 시도 방지
    IF NOT EXISTS (SELECT 1 FROM exam_subject WHERE exam_subject_id = p_exam_subject_id) THEN
        SET p_status = -1;
    -- name이 NULL이 아니고 빈 문자열인 경우
    ELSEIF p_name IS NOT NULL AND LTRIM(RTRIM(p_name)) = '' THEN
        SET p_status = -2; -- name은 NULL이거나 빈 문자열일 수 없음
    ELSE
        START TRANSACTION;

        UPDATE exam_subject
        SET
            category_id = COALESCE(p_category_id, category_id),
            organization_id = COALESCE(p_organization_id, organization_id),
            name = COALESCE(p_name, name),
            description = COALESCE(p_description, description),
            add_info = COALESCE(p_add_info, add_info)
        WHERE
            exam_subject_id = p_exam_subject_id;

        -- 실제 업데이트된 행이 있는지 확인 (해당 ID가 존재하지만 변경사항이 없을 수도 있음)
        IF ROW_COUNT() > 0 THEN
            SET p_status = 0; -- 성공
        ELSE
            -- ID는 존재하지만, 업데이트할 값이 모두 NULL이거나 기존 값과 동일한 경우
            SET p_status = 0; -- 변경 사항 없음으로 간주하고 성공으로 처리
        END IF;

        COMMIT;
    END IF;
END //

DELIMITER ;
-- 자격증 상세 정보 삭제
DELIMITER //

CREATE PROCEDURE delete_exam_detail(
    IN p_exam_subject_id BIGINT,
    OUT p_status INT             -- 0: 성공, -1: 찾을 수 없음, -2: 기타 오류 (FK 종속성 등)
)
BEGIN
    -- 에러 핸들러 선언
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- 자식 테이블에 참조되는 경우 (FK 위반)
        IF SQLSTATE = '23000' THEN
            SET p_status = -2; -- FK 종속성 등으로 인한 삭제 실패
        ELSE
            SET p_status = -3; -- 기타 오류
        END IF;
    END;

    -- 삭제 전에 레코드가 존재하는지 확인 (멱등성)
    IF NOT EXISTS (SELECT 1 FROM exam_subject WHERE exam_subject_id = p_exam_subject_id) THEN
        SET p_status = -1; -- 레코드를 찾을 수 없음
    ELSE
        START TRANSACTION;

        DELETE FROM exam_subject WHERE exam_subject_id = p_exam_subject_id;

        -- 삭제가 성공했는지 확인
        IF ROW_COUNT() > 0 THEN
            SET p_status = 0; -- 성공
        ELSE
            -- 해당 ID는 존재하지만, 어떤 이유로 삭제되지 않음 (매우 드문 경우)
            SET p_status = -2; -- 일반적인 오류로 처리
        END IF;

        COMMIT;
    END IF;
END //

DELIMITER ;

/* 커리큘럼 */
-- 커리큘럼 등록
DELIMITER //

CREATE PROCEDURE create_curriculum(
    IN p_exam_subject_id BIGINT,
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    OUT p_status INT,             -- 0: 성공, -1: 필수 값 누락, -2: FK 오류, -3: 기타 오류
    OUT p_new_curriculum_id BIGINT
)
BEGIN
    -- 에러 핸들러 선언
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        IF SQLSTATE = '23000' THEN -- Integrity constraint violation (FK or NOT NULL)
            SET p_status = -2; -- FK 오류 또는 NOT NULL 제약 조건 위반 등
        ELSE
            SET p_status = -3; -- 기타 오류
        END IF;
        SET p_new_curriculum_id = NULL;
    END;

    -- 필수 값 (name) 검사
    IF p_name IS NULL OR LTRIM(RTRIM(p_name)) = '' THEN
        SET p_status = -1;
        SET p_new_curriculum_id = NULL;
    ELSE
        START TRANSACTION;

        INSERT INTO curriculum (exam_subject_id, name, description)
        VALUES (p_exam_subject_id, p_name, p_description);

        SET p_new_curriculum_id = LAST_INSERT_ID(); -- 새로 삽입된 ID 가져오기
        SET p_status = 0; -- 성공

        COMMIT;
    END IF;
END //

DELIMITER ;
-- 커리큘럼 수정
DELIMITER //

CREATE PROCEDURE update_curriculum(
    IN p_curriculum_id BIGINT,
    IN p_exam_subject_id BIGINT, -- 커리큘럼이 다른 자격증으로 변경될 수 있다고 가정 (FK)
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    OUT p_status INT             -- 0: 성공, -1: ID 찾을 수 없음, -2: name NULL 오류, -3: FK 오류, -4: 기타 오류
)
BEGIN
    -- 에러 핸들러 선언
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        IF SQLSTATE = '23000' THEN
            SET p_status = -3; -- FK 오류 또는 NOT NULL 제약 조건 위반 등
        ELSE
            SET p_status = -4; -- 기타 오류
        END IF;
    END;

    -- 존재하지 않는 ID에 대한 업데이트 시도 방지
    IF NOT EXISTS (SELECT 1 FROM curriculum WHERE curriculum_id = p_curriculum_id) THEN
        SET p_status = -1;
    -- name이 NULL이 아니고 빈 문자열인 경우
    ELSEIF p_name IS NOT NULL AND LTRIM(RTRIM(p_name)) = '' THEN
        SET p_status = -2; -- name은 NULL이거나 빈 문자열일 수 없음
    ELSE
        START TRANSACTION;

        UPDATE curriculum
        SET
            exam_subject_id = COALESCE(p_exam_subject_id, exam_subject_id),
            name = COALESCE(p_name, name),
            description = COALESCE(p_description, description)
        WHERE
            curriculum_id = p_curriculum_id;

        -- 실제 업데이트된 행이 있는지 확인 (해당 ID가 존재하지만 변경사항이 없을 수도 있음)
        IF ROW_COUNT() > 0 THEN
            SET p_status = 0; -- 성공
        ELSE
            -- ID는 존재하지만, 업데이트할 값이 모두 NULL이거나 기존 값과 동일한 경우
            SET p_status = 0; -- 변경 사항 없음으로 간주하고 성공으로 처리
        END IF;

        COMMIT;
    END IF;
END //

DELIMITER ;
-- 커리큘럼 삭제
DELIMITER //

CREATE PROCEDURE delete_curriculum(
    IN p_curriculum_id BIGINT,
    OUT p_status INT             -- 0: 성공, -1: 찾을 수 없음, -2: 기타 오류 (FK 종속성 등)
)
BEGIN
    -- 에러 핸들러 선언
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- 자식 테이블에 참조되는 경우 (FK 위반)
        IF SQLSTATE = '23000' THEN
            SET p_status = -2; -- FK 종속성 등으로 인한 삭제 실패
        ELSE
            SET p_status = -3; -- 기타 오류
        END IF;
    END;

    -- 삭제 전에 레코드가 존재하는지 확인 (멱등성)
    IF NOT EXISTS (SELECT 1 FROM curriculum WHERE curriculum_id = p_curriculum_id) THEN
        SET p_status = -1; -- 레코드를 찾을 수 없음
    ELSE
        START TRANSACTION;

        DELETE FROM curriculum WHERE curriculum_id = p_curriculum_id;

        -- 삭제가 성공했는지 확인
        IF ROW_COUNT() > 0 THEN
            SET p_status = 0; -- 성공
        ELSE
            -- 해당 ID는 존재하지만, 어떤 이유로 삭제되지 않음 (매우 드문 경우)
            SET p_status = -2; -- 일반적인 오류로 처리
        END IF;

        COMMIT;
    END IF;
END //

DELIMITER ;
-- 커리큘럼 조회
DELIMITER //

CREATE PROCEDURE select_curriculum(
    IN p_exam_subject_id BIGINT
)
BEGIN
    SELECT
        c.curriculum_id,
        c.exam_subject_id,
        es.name AS exam_subject_name, -- exam_subject 테이블과 조인하여 이름도 가져옴
        c.name,
        c.description,
        c.created_at,
        c.updated_at
    FROM
        curriculum c
    LEFT JOIN
        exam_subject es ON c.exam_subject_id = es.exam_subject_id
    WHERE
        c.exam_subject_id = p_exam_subject_id
    ORDER BY
        c.name; -- 필요에 따라 정렬 기준 변경
END //

DELIMITER ;

/* 장바구니 */
-- 커리큘럼 추가
DELIMITER //

CREATE PROCEDURE add_cart(
    IN p_curriculum_id BIGINT,
    IN p_user_id BIGINT,
    OUT p_status INT              -- 0: 성공, -1: 필수 값 누락, -2: 중복, -3: FK 오류, -4: 기타 오류
)
BEGIN
    -- 에러 핸들러 선언
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        IF SQLSTATE = '23000' THEN -- Integrity constraint violation (FK or NOT NULL)
            SET p_status = -3; -- FK 오류 또는 NOT NULL 제약 조건 위반 등
        ELSE
            SET p_status = -4; -- 기타 오류
        END IF;
    END;

    -- 필수 값 (curriculum_id, user_id) 검사
    IF p_curriculum_id IS NULL OR p_user_id IS NULL THEN
        SET p_status = -1;
    ELSE
        -- 중복 추가 방지
        IF EXISTS (SELECT 1 FROM cart WHERE curriculum_id = p_curriculum_id AND user_id = p_user_id) THEN
            SET p_status = -2; -- 이미 장바구니에 존재함
        ELSE
            START TRANSACTION;

            INSERT INTO cart (curriculum_id, user_id)
            VALUES (p_curriculum_id, p_user_id);

            SET p_status = 0; -- 성공

            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;
-- 커리큘럼 삭제
DELIMITER //

CREATE PROCEDURE delete_cart(
    IN p_cart_id BIGINT,
    OUT p_status INT             -- 0: 성공, -1: 찾을 수 없음, -2: 기타 오류
)
BEGIN
    -- 에러 핸들러 선언
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = -2; -- 기타 오류
    END;

    -- 삭제 전에 레코드가 존재하는지 확인 (멱등성)
    IF NOT EXISTS (SELECT 1 FROM cart WHERE cart_id = p_cart_id) THEN
        SET p_status = -1; -- 레코드를 찾을 수 없음
    ELSE
        START TRANSACTION;

        DELETE FROM cart WHERE cart_id = p_cart_id;

        -- 삭제가 성공했는지 확인
        IF ROW_COUNT() > 0 THEN
            SET p_status = 0; -- 성공
        ELSE
            -- 해당 ID는 존재하지만, 어떤 이유로 삭제되지 않음 (매우 드문 경우)
            SET p_status = -2; -- 일반적인 오류로 처리
        END IF;

        COMMIT;
    END IF;
END //

DELIMITER ;
