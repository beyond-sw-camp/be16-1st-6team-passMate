-- 1. 커리큘럼 등록 및 일정 생성
-- 커리큘럼 생성: 특정 유저가 자격시험에 맞춘 커리큘럼 생성
insert into curriculum (user_id, exam_subject_id, name)
values (1, 1, '정보처리기사 커리큘럼');

-- 일정 생성
insert into event (user_id, exam_subject_id, title, subjects, start_date, end_date)
values (1, 1, '운영체제 공부', '프로세스, 스케줄링', '2025-06-10', '2025-06-15');

-- 방금 만든 커리큘럼과 일정 연결
insert into curriculum_event (curriculum_id, event_id)
values (1, 1);  

select * from event where user_id = 1;

-- 2. 일정 수정
-- 일정 수정: 기존 일정을 수정
update event
set title = '정보처리기사 실기 공부',
    subjects = '데이터베이스, 보안',
    start_date = '2025-06-15',
    end_date = '2025-06-25'
where event_id = 2;

select * from event where user_id = 1;

-- 3. 일정 삭제
-- EV_03 일정 삭제: 특정 일정을 삭제
delete from event
where event_id = 2;

-- 4. 세부 카테고리 추가
-- 종목 상세 추가: 이벤트에 대해 세부 과목을 추가함
insert into subject_detail (event_id, name)
values 
(1, '운영체제'), 
(1, '네트워크'),
(1, '데이터베이스');

select * from event inner join subject_detail on event.event_id = subject_detail.event_id;

-- 5. 복습 주기 추가
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

-- -----------------------

-- NT_01 노트 생성: 특정 일정(event)에 대해 노트를 작성
insert into note (user_id, event_id, title, content)
values (1, 10, '운영체제 정리', '프로세스 상태, 스케줄링 알고리즘 정리');

-- NT_02 노트 수정: 제목 및 내용 변경
update note
set title = '운영체제 핵심 요약',
    content = '프로세스 상태 5단계, RR, SJF 스케줄링 비교',
    updated_at = current_timestamp
where note_id = 5;

-- NT_03 노트 삭제: 특정 노트를 삭제
delete from note
where note_id = 5;


-----------------------------
-- TD_01 To Do List 생성: 사용자가 할 일을 추가함
insert into task (user_id, content, task_date)
values (1, '운영체제 복습하기', '2025-06-11 09:00:00');

-- TD_02 To Do List 수정: 내용, 날짜, 완료 여부 수정
update task
set content = '운영체제 핵심 정리하기',
    task_date = '2025-06-12 10:00:00',
    is_done = true
where task_id = 5;

-- TD_03 To Do List 삭제: 특정 할 일을 제거함
delete from task
where task_id = 5;

-----------------------------------------

-- 


