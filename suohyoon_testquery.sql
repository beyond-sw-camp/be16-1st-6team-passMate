/* 카테고리 */
/* 카테고리 조회 */
CALL get_exam_subjects_by_category(1);
/* 카테고리 생성 */
CALL insert_category('국가기술자격', '정보기술', '정보처리기능사');
CALL insert_category('국가기술자격', '정보기술', '정보처리기사');
/* 카테고리 수정 */
CALL update_category(3, 2, '정보보안');
CALL update_category(3, 2, '정보보안');
-- 카테고리 삭제
CALL delete_category(5);

/* 자격증 */
-- 자격증 상세 정보 조회
CALL select_exam_detail(1);
-- 자격증 상세 정보 생성
SET @status = 0;
SET @new_id = NULL;
CALL create_exam_detail(1, 1, 'SQLD', '데이터베이스 SQL 개발자 자격증입니다.', '추가 정보', @status, @new_id);
SELECT @status AS Status, @new_id AS NewExamSubjectId;
-- 필수 값 누락 시도
SET @status = 0;
SET @new_id = NULL;
CALL create_exam_detail(1, 1, NULL, '설명', '정보', @status, @new_id);
SELECT @status AS Status, @new_id AS NewExamSubjectId;
-- 존재하지 않는 FK 시도
SET @status = 0;
SET @new_id = NULL;
CALL create_exam_detail(9999, 1, '잘못된 카테고리', '설명', '정보', @status, @new_id);
SELECT @status AS Status, @new_id AS NewExamSubjectId;

/* 자격증 상세 정보 수정 */
SET @status = 0;
CALL update_exam_detail(1, NULL, NULL, '새로운 SQL 자격증 이름', '업데이트된 설명', NULL, @status);
SELECT @status AS Status;

SET @status = 0;
CALL update_exam_detail(1, 2, NULL, NULL, NULL, NULL, @status);
SELECT @status AS Status;

SET @status = 0;
CALL update_exam_detail(999, NULL, NULL, '없는 ID', NULL, NULL, @status);
SELECT @status AS Status;

SET @status = 0;
CALL update_exam_detail(1, 9999, NULL, NULL, NULL, NULL, @status);
SELECT @status AS Status;

/* 자격증 상세 정보 삭제 */
SET @status = 0;
CALL delete_exam_detail(1, @status);
SELECT @status AS Status;

SET @status = 0;
CALL delete_exam_detail(999, @status);
SELECT @status AS Status;

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
-- 커리큘럼 추가
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

-- 커리큘럼 삭제
SET @status = 0;
-- 먼저 장바구니에 항목을 추가하여 삭제할 항목을 만듭니다. (예: cart_id가 1인 항목)
-- CALL AddCurriculumToCart(1, 1, @dummy_status);
CALL delete_cart(1, @status); -- cart_id가 1인 항목 삭제
SELECT @status AS Status;

SET @status = 0;
CALL delete_cart(999, @status); -- 존재하지 않는 cart_id 시도
SELECT @status AS Status;



