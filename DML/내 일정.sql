-- 1. 커리큘럼 등록 및 일정 생성
-- 커리큘럼 생성: 특정 유저가 자격시험에 맞춘 커리큘럼 생성
insert into curriculum (user_id, exam_subject_id, name)
values (1, 1, '정보처리기사 커리큘럼');

-- EV_01: 일정 생성
insert into event (user_id, exam_subject_id, title, subjects, start_date, end_date)
values (1, 1, '운영체제 공부', '프로세스, 스케줄링', '2025-06-10', '2025-06-15');

-- 방금 만든 커리큘럼과 일정 연결
insert into curriculum_event (curriculum_id, event_id)
values (1, 1);  

select * from event where user_id = 1;

-- EV_02: 일정 수정
-- 일정 수정: 기존 일정을 수정
update event
set title = '정보처리기사 실기 공부',
    subjects = '데이터베이스, 보안',
    start_date = '2025-06-15',
    end_date = '2025-06-25'
where event_id = 2;

select * from event where user_id = 1;

-- EV_03: 일정 삭제
-- 일정 삭제: 특정 일정을 삭제
delete from event
where event_id = 2;

-- EV_04: 세부 카테고리 추가
-- 종목 상세 추가: 이벤트에 대해 세부 과목을 추가함
insert into subject_detail (event_id, name)
values 
(1, '운영체제'), 
(1, '네트워크'),
(1, '데이터베이스');

select * from event inner join subject_detail on event.event_id = subject_detail.event_id;

-- EV_05: 복습 주기 추가
-- 복습 주기 등록: 특정 일정(event)에 대해 반복 주기 설정
insert into repetition (event_id, repeat_interval, interval_times, repeat_times)
values (1, 'WEEKLY', 1, 4);

select * from repetition;


-- 일정 등록 프로시저 
delimiter //

create procedure 등록_커리큘럼_일정_복습 (
    in p_user_id bigint,
    in p_exam_subject_id bigint,
    in p_curriculum_name varchar(255),
    
    in p_event_title varchar(255),
    in p_event_subjects varchar(255),
    in p_event_start date,
    in p_event_end date,

    in p_repeat_interval enum('DAILY', 'WEEKLY', 'MONTHLY'),
    in p_interval_times int,
    in p_repeat_times int,

    in p_subject_detail_1 varchar(255),
    in p_subject_detail_2 varchar(255),
    in p_subject_detail_3 varchar(255)
)
begin
    declare v_curriculum_id bigint;
    declare v_event_id bigint;

    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- 1. 커리큘럼 생성
    insert into curriculum (user_id, exam_subject_id, name)
    values (p_user_id, p_exam_subject_id, p_curriculum_name);

    set v_curriculum_id = last_insert_id();

    -- 2. 일정 생성
    insert into event (user_id, exam_subject_id, title, subjects, start_date, end_date)
    values (p_user_id, p_exam_subject_id, p_event_title, p_event_subjects, p_event_start, p_event_end);

    set v_event_id = last_insert_id();

    -- 3. 커리큘럼-일정 연결
    insert into curriculum_event (curriculum_id, event_id)
    values (v_curriculum_id, v_event_id);

    -- 4. 세부 과목 등록 (최대 3개)
    if p_subject_detail_1 is not null then
        insert into subject_detail (event_id, name) values (v_event_id, p_subject_detail_1);
    end if;
    if p_subject_detail_2 is not null then
        insert into subject_detail (event_id, name) values (v_event_id, p_subject_detail_2);
    end if;
    if p_subject_detail_3 is not null then
        insert into subject_detail (event_id, name) values (v_event_id, p_subject_detail_3);
    end if;

    -- 5. 복습 설정
    insert into repetition (event_id, repeat_interval, interval_times, repeat_times)
    values (v_event_id, p_repeat_interval, p_interval_times, p_repeat_times);

    commit;
end //

delimiter ;
CALL passmate_등록_커리큘럼_일정_생성(1, 1, 1, '정재한', '데이터베이스설계', 'mysql강좌 및 데이터베이스관련 기초 전반적인 공부', '2024-01-01', '2024-02-03', 'MONTHLY', 1, 2, 'mysql', 'oracle', null);