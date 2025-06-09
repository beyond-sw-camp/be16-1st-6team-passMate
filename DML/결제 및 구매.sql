-- PAY_01: 결제 수단 추가
-- 카드 결제수단 추가
INSERT INTO method (user_id, type, account) 
VALUES (1, 'CARD', '1234-5678-9012-3456');

-- 계좌 결제수단 추가  
INSERT INTO method (user_id, type, account)
VALUES (1, 'BANK', '110-123-456789');

-- 결제수단 등록 확인
SELECT * FROM method WHERE user_id = 1;

-- PAY_02: 결제 수단 삭제
update method set is_deleted=true where method_id = 결제수단ID AND user_id=유저ID; -- payment 테이블에 외래키 걸려있어서 삭제 불가능 -> method 에 활성, 비활성 구분 가능한 컬럼 하나 추가해서 관리하면 될듯
-- 삭제 후 확인
SELECT * FROM method WHERE user_id = 1;
-- alter table method add column is_deleted boolean default false;

-- PAY_03: 환불
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

-- PAY_04: 구매 가능한 커리큘럼 조회
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

-- PAY_05: 구매
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
-- 결제 완료 확인
SELECT * FROM payment WHERE payment_id = LAST_INSERT_ID();

-- PAY_06: 구매확정
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

-- PAY_07: 결제 내역 조회
-- 상세 결제 내역 조회
SELECT 
    p.payment_id,
    cs.title as curriculum_title,
    cs.price,
    m.type as payment_method,
    m.account as payment_account,
    p.status,
    p.date as payment_date,
    p.confirm,
    p.is_refund,
    u.nickname as seller_name,
    CASE 
        WHEN p.is_refund = true THEN '환불완료'
        WHEN p.status = 'STANBY' THEN '결제대기'
        WHEN p.status = 'IN_PROGRESS' THEN '결제진행중'
        WHEN p.status = 'COMPLETE' AND p.confirm = false THEN '결제완료(확정대기)'
        WHEN p.status = 'COMPLETE' AND p.confirm = true THEN '구매확정'
        ELSE '상태불명'
    END as transaction_status,
    CASE 
        WHEN p.is_refund = true THEN '환불됨'
        WHEN p.status = 'COMPLETE' AND p.confirm = false AND DATEDIFF(NOW(), p.date) < 7 THEN '환불가능'
        WHEN p.status = 'COMPLETE' AND p.confirm = true THEN '환불불가(구매확정)'
        WHEN p.status = 'COMPLETE' AND DATEDIFF(NOW(), p.date) >= 7 THEN '환불불가(기간만료)'
        ELSE '환불불가(결제대기)'
    END as refund_status
FROM payment p
JOIN curriculum_sale cs ON p.curriculum_sale_id = cs.curriculum_sale_id
JOIN method m ON p.method_id = m.method_id
JOIN user u ON cs.seller_id = u.user_id
WHERE p.user_id = 1
ORDER BY p.date DESC;