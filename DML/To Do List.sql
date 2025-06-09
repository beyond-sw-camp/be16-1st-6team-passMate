-- TDL_01: To Do List 생성: 사용자가 할 일을 추가함
insert into task (user_id, content, task_date)
values (1, '운영체제 복습하기', '2025-06-11 09:00:00');

-- TDL_02: To Do List 수정: 내용, 날짜, 완료 여부 수정
update task
set content = '운영체제 핵심 정리하기',
    task_date = '2025-06-12 10:00:00',
    is_done = true
where task_id = 5;

-- TDL_03: To Do List 삭제: 특정 할 일을 제거함
delete from task
where task_id = 5;