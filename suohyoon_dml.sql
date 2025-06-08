/* 카테고리 */
-- 카테고리 조회
select j.name as '직무', c.name as '자격증' from category as c
left join job_field as j on c.job_field_id = j.job_field_id
where j.name = '정보기술';

-- 카테고리 생성
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

DELIMITER ;
-- 카테고리 수정
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

/* 자격증 */
/* 자격증 상세 정보 조회 */
-- 정보처리기사 자격증에 대한 시험 정보 조회
SELECT DISTINCT
    es.name as '자격증명', es.description as '설명',
    ei.year as '연도', ei.session as '회차', ei.applicants as '응시자수', ei.passer_cnt as '합껵자수', ei.pass_ratio as '합격률',
    esch.exam_type as '시험 종류', esch.apply_start as '원서접수 시작일', esch.apply_end as '원서접수 마감일', esch.exam_date as '시험일', esch.result_date as '결과발표일',
    ef.amount as '비용',
    o.name as '시행기관', o.phone as '전화번호', o.homepage as '홈페이지'
FROM category c
JOIN exam_subject es ON c.category_id = es.category_id
JOIN exam_info ei ON es.exam_subject_id = ei.exam_subject_id
LEFT JOIN exam_schedule esch ON ei.exam_info_id = esch.exam_info_id
LEFT JOIN exam_fee ef ON es.exam_subject_id = ef.exam_subject_id
LEFT JOIN past_exam pe ON es.exam_subject_id = pe.exam_subject_id
LEFT JOIN exam e ON pe.past_exam_id = e.past_exam_id
JOIN organization o ON es.organization_id = o.organization_id
WHERE es.name = '정보처리기사' and esch.exam_type = '실기' and ef.fee_type = '실기'
LIMIT 1000;
/* 자격증 상세 정보 생성 */
/* 기관정보 삽입 */
INSERT INTO `organization` (`name`, `phone`, `homepage`) VALUES ('한국산업인력공단', '1644-8000', 'https://www.hrdkorea.or.kr/');
/* 시험 종목 삽입 */
INSERT INTO `passmate`.`exam_subject` (`category_id`, `organization_id`, `name`, `description`) VALUES ('2', '1', '정보처리기사', 'Engineer Information Processing');
/* 시험 관련 비용 삽입 */
INSERT INTO `exam_fee` (`exam_subject_id`, `fee_type`, `amount`) VALUES ('1', '필기', '19400');
INSERT INTO `exam_fee` (`exam_subject_id`, `fee_type`, `amount`) VALUES ('1', '실기', '22600');

/* 시험 정보 삽입 */
INSERT INTO `exam_info` (`exam_subject_id`, `year`, `session`, `applicants`, `passer_cnt`, `pass_ratio`) VALUES ('1', '2024-01-01', '1', '25188', '9263', '36.78');
INSERT INTO `exam_info` (`exam_subject_id`, `year`, `session`, `applicants`, `passer_cnt`, `pass_ratio`) VALUES ('1', '2024-01-01', '2', '22682', '6292', '27.74');
INSERT INTO `exam_info` (`exam_subject_id`, `year`, `session`, `applicants`, `passer_cnt`, `pass_ratio`) VALUES ('1', '2024-01-01', '3', '20875', '4324', '20.71');

/* 시험 일정 삽입 */
INSERT INTO `exam_schedule` (`exam_info_id`, `exam_type`, `apply_start`, `apply_end`, `exam_date`, `result_date`) VALUES ('1', '팔기', '2024-01-23', '2024-01-26', '2024-03-07', '2024-03-13');
INSERT INTO `exam_schedule` (`exam_info_id`, `exam_type`, `apply_start`, `apply_end`, `exam_date`, `result_date`) VALUES ('1', '실기', '2024-03-26', '2024-03-29', '2024-05-12', '2024-06-18');
INSERT INTO `exam_schedule` (`exam_info_id`, `exam_type`, `apply_start`, `apply_end`, `exam_date`, `result_date`) VALUES ('2', '팔기', '2024-04-16', '2024-04-19', '2024-05-28', '2024-06-05');
INSERT INTO `exam_schedule` (`exam_info_id`, `exam_type`, `apply_start`, `apply_end`, `exam_date`, `result_date`) VALUES ('2', '실기', '2024-06-25', '2024-06-28', '2024-08-14', '2024-09-10');
INSERT INTO `exam_schedule` (`exam_info_id`, `exam_type`, `apply_start`, `apply_end`, `exam_date`, `result_date`) VALUES ('3', '팔기', '2024-06-18', '2024-06-21', '2024-07-27', '2024-08-07');
INSERT INTO `exam_schedule` (`exam_info_id`, `exam_type`, `apply_start`, `apply_end`, `exam_date`, `result_date`) VALUES ('3', '실기', '2024-09-10', '2024-09-13', '2024-11-08', '2024-12-11');

/* 문제 삽입 */
INSERT INTO `passmate`.`question` (`question_id`, `content`, `image_url`, `answer`) VALUES ('2', 'LRU에 대해 약술하시오?', 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fcoding-factory.tistory.com%2F865&psig=AOvVaw3Pgst8Ng9CePd28zztjN0k&ust=1749475173743000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJjn_YP14Y0DFQAAAAAdAAAAABAE', 'LRU는 가장 오랫동안 사용되지 않은 데이터를 우선 제거하는 캐시 교체 알고리즘입니다.
');
INSERT INTO `passmate`.`question` (`question_id`, `content`, `image_url`, `answer`) VALUES ('2', '자바 클래스에서 상속을 받는 키워드는?', 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fcoding-factory.tistory.com%2F865&psig=AOvVaw3Pgst8Ng9CePd28zztjN0k&ust=1749475173743000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJjn_YP14Y0DFQAAAAAdAAAAABAE', 'extends');

/* 기출문제 삽입 */
INSERT INTO `passmate`.`past_exam` (`exam_subject_id`, `exam_info_id`) VALUES ('1', '1');
INSERT INTO `passmate`.`past_exam` (`exam_subject_id`, `exam_info_id`) VALUES ('1', '2');
INSERT INTO `passmate`.`past_exam` (`exam_subject_id`, `exam_info_id`) VALUES ('1', '3');

/* 시험 삽입 */
INSERT INTO `passmate`.`exam` (`question_id`, `past_exam_id`) VALUES ('1', '1');
INSERT INTO `passmate`.`exam` (`question_id`, `past_exam_id`) VALUES ('2', '1');
INSERT INTO `passmate`.`exam` (`question_id`, `past_exam_id`) VALUES ('1', '2');
INSERT INTO `passmate`.`exam` (`question_id`, `past_exam_id`) VALUES ('2', '2');
INSERT INTO `passmate`.`exam` (`question_id`, `past_exam_id`) VALUES ('1', '3');
INSERT INTO `passmate`.`exam` (`question_id`, `past_exam_id`) VALUES ('2', '3');


/* 자격증 상세 정보 수정 */
-- 1. 조직 수정
UPDATE organization
SET name = '한국산업인력공단',
	phone = '1644-8000',
	homepage = 'https://www.hrdkorea.or.kr/'
WHERE organization_id = 1;

-- 2. 자격시험 과목
UPDATE exam_subject
SET category_id = 2,
	organization_id = 1,
	name = '정보처리기사',
	description = 'Engineer Information Processing'
WHERE exam_subject_id = 1;

-- 3. 시험 비용
UPDATE exam_fee
SET amount = 19400
WHERE exam_subject_id = 1 AND fee_type = '필기';

UPDATE exam_fee
SET amount = 22600
WHERE exam_subject_id = 1 AND fee_type = '실기';

-- 4. 시험 정보
UPDATE exam_info
SET year = '2024-01-01', session = '1',
	applicants = 25188, passer_cnt = 9263, pass_ratio = 36.78
WHERE exam_info_id = 1;

UPDATE exam_info
SET year = '2024-01-01', session = '2',
	applicants = 22682, passer_cnt = 6292, pass_ratio = 27.74
WHERE exam_info_id = 2;

UPDATE exam_info
SET year = '2024-01-01', session = '3',
	applicants = 20875, passer_cnt = 4324, pass_ratio = 20.71
WHERE exam_info_id = 3;

-- 5. 시험 일정
UPDATE exam_schedule
SET exam_type = '팔기', apply_start = '2024-01-23', apply_end = '2024-01-26',
	exam_date = '2024-03-07', result_date = '2024-03-13'
WHERE exam_schedule_id = 1;

UPDATE exam_schedule
SET exam_type = '실기', apply_start = '2024-03-26', apply_end = '2024-03-29',
	exam_date = '2024-05-12', result_date = '2024-06-18'
WHERE exam_schedule_id = 2;

UPDATE exam_schedule
SET exam_type = '팔기', apply_start = '2024-04-16', apply_end = '2024-04-19',
	exam_date = '2024-05-28', result_date = '2024-06-05'
WHERE exam_schedule_id = 3;

UPDATE exam_schedule
SET exam_type = '실기', apply_start = '2024-06-25', apply_end = '2024-06-28',
	exam_date = '2024-08-14', result_date = '2024-09-10'
WHERE exam_schedule_id = 4;

UPDATE exam_schedule
SET exam_type = '팔기', apply_start = '2024-06-18', apply_end = '2024-06-21',
	exam_date = '2024-07-27', result_date = '2024-08-07'
WHERE exam_schedule_id = 5;

UPDATE exam_schedule
SET exam_type = '실기', apply_start = '2024-09-10', apply_end = '2024-09-13',
	exam_date = '2024-11-08', result_date = '2024-12-11'
WHERE exam_schedule_id = 6;

-- 6. 문제
UPDATE question
SET content = 'LRU에 대해 약술하시오?',
	image_url = 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fvelog.io%2F%40kingyong9169%2F%25ED%258E%2598%25EC%259D%25B4%25EC%25A7%2580-%25EA%25B5%2590%25EC%25B2%25B4-%25EC%2595%258C%25EA%25B3%25A0%25EB%25A6%25AC%25EC%25A6%2598-LRU&psig=AOvVaw15U6olLOFAQRxm4mi41NXT&ust=1749475243885000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCOjOzqX14Y0DFQAAAAAdAAAAABAE',
	answer = 'LRU는 가장 오랫동안 사용되지 않은 데이터를 우선 제거하는 캐시 교체 알고리즘입니다.'
WHERE question_id = 1;

UPDATE question
SET content = '자바 클래스에서 상속을 받는 키워드는?',
	image_url = 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fcoding-factory.tistory.com%2F865&psig=AOvVaw3Pgst8Ng9CePd28zztjN0k&ust=1749475173743000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJjn_YP14Y0DFQAAAAAdAAAAABAE',
	answer = 'extends'
WHERE question_id = 2;

-- 7. 과거 시험
UPDATE past_exam
SET exam_subject_id = 1, exam_info_id = 1
WHERE past_exam_id = 1;

UPDATE past_exam
SET exam_subject_id = 1, exam_info_id = 2
WHERE past_exam_id = 2;

UPDATE past_exam
SET exam_subject_id = 1, exam_info_id = 3
WHERE past_exam_id = 3;

-- 8. 시험
UPDATE exam SET question_id = 1, past_exam_id = 1 WHERE exam_id = 1;
UPDATE exam SET question_id = 2, past_exam_id = 1 WHERE exam_id = 2;
UPDATE exam SET question_id = 1, past_exam_id = 2 WHERE exam_id = 3;
UPDATE exam SET question_id = 2, past_exam_id = 2 WHERE exam_id = 4;
UPDATE exam SET question_id = 1, past_exam_id = 3 WHERE exam_id = 5;
UPDATE exam SET question_id = 2, past_exam_id = 3 WHERE exam_id = 6;

-- 자격증 상세 정보 삭제
call delete_exam_detail(1);
DELIMITER //

CREATE PROCEDURE delete_exam_detail(
    IN p_exam_subject_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- 1. exam 삭제
    DELETE FROM exam
    WHERE past_exam_id IN (
        SELECT past_exam_id
        FROM past_exam
        WHERE exam_subject_id = p_exam_subject_id
    );

    -- 2. past_exam 삭제
    DELETE FROM past_exam
    WHERE exam_subject_id = p_exam_subject_id;

    -- 3. exam_subject 삭제
    DELETE FROM exam_subject
    WHERE exam_subject_id = p_exam_subject_id;

    COMMIT;

    -- 삭제 확인용 (없어야 정상)
    SELECT *
    FROM exam_subject
    WHERE exam_subject_id = p_exam_subject_id;
END //

DELIMITER ;

/* 커리큘럼 */
-- 커리큘럼 등록
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

-- 커리큘럼 수정
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

-- 커리큘럼 삭제
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

-- 커리큘럼 조회(카테고리 = 정보처리기사)
select * from curriculum where exam_subject_id = 1;

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
