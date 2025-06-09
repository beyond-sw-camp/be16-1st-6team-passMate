-- QF_01: 자격증 상세 정보 조회
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
-- QF_02: 자격증 상세 정보 생성
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


-- QF_03: 자격증 상세 정보 수정
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

-- QF_04: 자격증 상세 정보 삭제
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
call delete_exam_detail(1);