/* 카테고리 */
/* 카테고리 조회 */
CALL get_exam_subjects_by_category(1);
/* 카테고리 생성 */
CALL insert_category('국가기술자격', '정보기술', '정보처리기능사');
CALL insert_category('국가기술자격', '정보기술', '정보처리기사');
/* 카테고리 수정 */
CALL update_category(1, 1, '정보보안기능사');
CALL update_category(1, 2, '정보보안기사');
-- 카테고리 삭제
CALL delete_category(2);

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

/* 자격증 상세 정보 삭제 */
call delete_exam_detail(1);


/* 커리큘럼 */
/* 커리큘럼 등록 */
SET @status = 0;
SET @new_id = NULL;
CALL create_curriculum(1, '데이터베이스 기초 커리큘럼', '관계형 데이터베이스의 기초를 다루는 초급자용 SQLD 커리큘럼입니다.', @status, @new_id);
SELECT @status AS Status, @new_id AS NewCurriculumId;

-- 필수 값 누락 시도
SET @status = 0;
SET @new_id = NULL;
CALL create_curriculum(1, NULL, '설명', @status, @new_id);
SELECT @status AS Status, @new_id AS NewCurriculumId;

-- 존재하지 않는 exam_subject_id 시도
SET @status = 0;
SET @new_id = NULL;
CALL create_curriculum(9999, '잘못된 자격증 커리큘럼', '설명', @status, @new_id);
SELECT @status AS Status, @new_id AS NewCurriculumId;
/* 커리큘럼 수정 */
SET @status = 0;
CALL update_curriculum(1, NULL, '데이터베이스 중급 커리큘럼', '중급자를 위한 SQLP 커리큘럼입니다.', @status);
SELECT @status AS Status;

SET @status = 0;
CALL update_curriculum(1, 2, '다른 자격증으로 변경', NULL, @status);
SELECT @status AS Status;

SET @status = 0;
CALL update_curriculum(999, NULL, '없는 ID', NULL, @status);
SELECT @status AS Status;

SET @status = 0;
CALL update_curriculum(1, 9999, '잘못된 FK', NULL, @status);
SELECT @status AS Status;

/* 커리큘럼 삭제 */
SET @status = 0;
CALL delete_curriculum(1, @status);
SELECT @status AS Status;

SET @status = 0;
CALL delete_curriculum(999, @status);
SELECT @status AS Status;

/* 커리큘럼 조회 */
CALL select_curriculum(1);

/* 장바구니 */
/* 커리큘럼 추가 */
SET @status = 0;
CALL add_cart(1, 1, @status); -- user_id 1의 장바구니에 curriculum_id 1 추가
SELECT @status AS Status;

SET @status = 0;
CALL add_cart(1, 1, @status); -- 중복 추가 시도
SELECT @status AS Status;

SET @status = 0;
CALL add_cart(999, 1, @status); -- 존재하지 않는 curriculum_id 시도
SELECT @status AS Status;

SET @status = 0;
CALL add_cart(1, 999, @status); -- 존재하지 않는 user_id 시도
SELECT @status AS Status;

/* 커리큘럼 삭제 */
SET @status = 0;
-- 먼저 장바구니에 항목을 추가하여 삭제할 항목을 만듭니다. (예: cart_id가 1인 항목)
-- CALL AddCurriculumToCart(1, 1, @dummy_status);
CALL delete_cart(1, @status); -- cart_id가 1인 항목 삭제
SELECT @status AS Status;

SET @status = 0;
CALL delete_cart(999, @status); -- 존재하지 않는 cart_id 시도
SELECT @status AS Status;



