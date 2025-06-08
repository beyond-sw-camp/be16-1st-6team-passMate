/* 회원가입 및 로그인 */
-- 회원가입
insert into user() values();
-- 로그인
select user_id from user where email = ?, password = ?;
-- 로그아웃(솔직히 이부분은 db영역이 아닌 서버의 세션 관리 영역이라고 생각합니다!)
-- 회원탈퇴
delete user where user_id = ?;

/* 마이페이지 */
-- 내정보 조회
select * from user where user_id = ?;
-- 내정보 수정
update user set nickname = ?, password = ?, profile_image = ?, job = ? where user_id = ?;
-- 정산일 설정;
update adjustment set adjusted_date = ? where adjustment_id = ?;
-- 정산 조회
select * from adjustment where user_id = ?;
-- 정산처리(정산완료 처리)
update adjustment set is_completed = ? where adjustment_id = ?;

/* 커리큘럼 */
-- 커리큘럼 등록
insert into curriculum() values();
-- 커리큘럼 수정
update curriculum set exam_subject = ?, name = ? where adjustment_id = ?;
-- 커리큘럼 삭제
delete curriculum where curriculum_id = ?;
-- 커리큘럼 조회
select * from curriculum where exam_subject_id = ?;

-- PAY_01: 결제 수단 추가(정지완)
-- 카드 결제수단 추가
INSERT INTO method (user_id, type, account) 
VALUES (1, 'CARD', '1234-5678-9012-3456');

-- 계좌 결제수단 추가  
INSERT INTO method (user_id, type, account)
VALUES (1, 'BANK', '110-123-456789');

-- PAY_02: 결제 수단 삭제(정지완)
update method set is_deleted=true where method_id = 결제수단ID AND user_id=유저ID; -- payment 테이블에 외래키 걸려있어서 삭제 불가능 -> method 에 활성, 비활성 구분 가능한 컬럼 하나 추가해서 관리하면 될듯
-- alter table method add column is_deleted boolean default false;

-- PAY_03: 환불(정지완)
-- alter table payment add column is_refund boolean default false;
-- 환불 가능여부 파악 가능한 구매내역 조회
SELECT 
    p.payment_id,
    cs.title as curriculum_title,
    cs.price,
    p.date as purchase_date,
    p.status,
    p.confirm,
    p.is_refund,
    u.nickname as seller_name,
    DATEDIFF(NOW(), p.date) as days_since_purchase,
    CASE 
        WHEN p.is_refund = true THEN '이미 환불됨'
        WHEN p.status != 'COMPLETE' THEN '결제 미완료'
        WHEN p.confirm = true THEN '구매확정으로 환불불가'
        WHEN DATEDIFF(NOW(), p.date) >= 7 THEN '7일 경과로 환불불가'
        ELSE '환불가능'
    END as refund_status
FROM payment p
JOIN curriculum_sale cs ON p.curriculum_sale_id = cs.curriculum_sale_id
JOIN user u ON cs.seller_id = u.user_id
WHERE p.user_id = 1 
AND p.status = 'COMPLETE'
AND p.is_refund = false  -- 환불되지 않은 것만
ORDER BY p.date DESC;
-- 환불 처리 (단일 건)
UPDATE payment 
SET is_refund = true
WHERE payment_id = 1 
AND user_id = 1 
AND status = 'COMPLETE' 
AND confirm = false
AND is_refund = false
AND DATEDIFF(NOW(), date) < 7;

-- PAY_04: 구매 가능한 커리큘럼 조회(정지완)
SELECT DISTINCT
    cs.curriculum_sale_id,
    cs.title,
    cs.price,
    cs.thumbnail_url,
    cs.description,
    u.nickname as seller_name,
    es.name as exam_subject_name,
    cs.created_at
FROM curriculum_sale cs
JOIN user u ON cs.seller_id = u.user_id
JOIN exam_subject es ON cs.exam_subject_id = es.exam_subject_id
WHERE cs.seller_id != 본인유저ID  -- 본인이 판매한 커리큘럼 제외
AND cs.curriculum_sale_id NOT IN (
    SELECT curriculum_sale_id 
    FROM payment 
    WHERE user_id = 본인유저ID AND status = 'COMPLETE'  -- 이미 구매한 커리큘럼 제외
)
ORDER BY cs.created_at DESC;

-- PAY_05: 구매(정지완)
-- 결제 시작
insert into payment(user_id, curriculum_sale_id, method_id, status) values(1, 1, 1, 'STANBY');
-- 결제 진행 중으로 상태 변경
UPDATE payment 
SET status = 'IN_PROGRESS'
WHERE payment_id = LAST_INSERT_ID();

-- 결제 완료 처리
UPDATE payment 
SET status = 'COMPLETE', date = CURRENT_TIMESTAMP
WHERE payment_id = LAST_INSERT_ID();

-- PAY_06: 구매확정(정지완)
-- 수동구매확정
UPDATE payment 
SET confirm = true
WHERE payment_id = 1 AND user_id = 1 AND status = 'COMPLETE';
-- 7일 경과 자동 구매 확정
UPDATE payment 
SET confirm = true
WHERE status = 'COMPLETE' 
AND confirm = false 
AND is_refund = false
AND date <= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- PAY_07: 결제 내역 조회(정지완)
-- 전체 결제 내역 조회
SELECT 
    p.payment_id,
    cs.title as curriculum_title,
    cs.price,
    m.type as payment_method,
    p.status,
    p.date as payment_date,
    p.confirm,
    u.nickname as seller_name,
    CASE 
        WHEN p.status = 'STANBY' THEN '결제 대기'
        WHEN p.status = 'IN_PROGRESS' THEN '결제 진행중'
        WHEN p.status = 'COMPLETE' AND p.confirm = false THEN '결제완료(확정대기)'
        WHEN p.status = 'COMPLETE' AND p.confirm = true THEN '구매확정'
    END as status_description
FROM payment p
JOIN curriculum_sale cs ON p.curriculum_sale_id = cs.curriculum_sale_id
JOIN method m ON p.method_id = m.method_id
JOIN user u ON cs.seller_id = u.user_id
WHERE p.user_id = 1
ORDER BY p.date DESC;

/* 자격증 */
-- 자격증 상세 정보 조회
select * from exam_subject where exam_subject_id = ?;
-- 자격증 상세 정보 생성
insert into exam_subject() values();
-- 자격증 상세 정보 수정
update exam_subject set category_id = ?, organization_id = ?, name = ?, description = ? where exam_subject_id = ?;
-- 자격증 상세 정보 삭제
delete exam_subject where id = ?

/* 카테고리 */
-- 카테고리 조회
select * from exam_subject where category_id = ?
-- 카테고리 생성
/*
1. 자격구분 데이터 insert
2. 직무분야 데이터 insert
3. 분류 데이터 insert
*/
insert into qualification_type() values();
insert into job_field() values();
insert into category() values();
-- 카테고리 수정
update category set job_field_id = ?, name = ? where category_id = ?;
-- 카테고리 삭제
delete category where category_id = ?;

/* 내 일정 */
-- 일정 생성
insert into qualification_type() values();
-- 일정 수정
-- 일정 삭제
delete event where event_id = ?;
-- 카테고리 선택
select * from category where exam_subject_id = ?;
-- 복습주기/회차 선택
select * from

/* ToDoList */
-- TDL 생성
insert into task() values();
-- TDL 수정
update task set content = ?, is_done = ? where task_id = ?;
-- TDL 삭제
delete task where task_id = ?;

/* 노트 */
-- 노트 생성
insert into note() values();
-- 노트 수정
update note set title = ?, content = ? where note_id = ?;
-- 노트 삭제
delete note where note_id = ?;

/* 즐겨찾기 */
-- 즐겨찾기 설정
insert into favorite() values();
-- 즐겨찾기 해제
delete favorite where favorite_id = ?;

/* 장바구니 */
-- 커리큘럼 추가
insert into cart() values();
-- 커리큘럼 삭제
delete cart where cart_id = ?;

/* 쪽지 */
-- 쪽지 보내기
insert into message() values();
-- 쪽지 읽기 및 쪽지함 새로고침
select * from message where sender_id =?, receiver_id = ?;
-- 쪽지 삭제
delete message where message_id = ?;
