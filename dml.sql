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

/* 결제 및 구매 */
-- 결제수단 추가
insert into method(user_id, type, account) values(유저가 제공한 정보);
-- 예시
-- insert 
-- into method(user_id, type, account) 
-- values(1, '카드', '1234-5678-1234-5678');

-- 결제 수단 삭제
update method set is_deleted=true where method_id = ?; -- payment 테이블에 외래키 걸려있어서 삭제 불가능 -> method 에 활성, 비활성 구분 가능한 컬럼 하나 추가해서 관리하면 될듯
-- alter table method add column is_deleted boolean default false;

-- 환불
update payment set is_refund=true where payment_id = ? and confirm=false; -- delete가 맞나? 컬럼 하나 환불여부로 추가해서 관리하는게 좋을듯
-- alter table payment add column is_refund boolean default false;

-- 구매 가능한 커리큘럼 조회
select * from curriculum_sale where is_seen = true; 
-- 사용자가 원하는 시험을 필터링 한다고 가정하면
select * from curriculu_sale inner join exam_subject on exam_subject_id=사용자가 원하는 시험 종목 id where is_seen = true;

-- 구매
insert into payment(user_id, curriculum_sale_id, method_id, status) values(1, 1, 1, 'STANBY');

-- 구매확정
update payment set confirm = true where payment_id = ?;

-- 결제 내역 조회
select * from payment where user_id = ?;

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
