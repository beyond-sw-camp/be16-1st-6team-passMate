-- NT_01: 노트 생성: 특정 일정(event)에 대해 노트를 작성
insert into note (user_id, event_id, title, content)
values (1, 10, '운영체제 정리', '프로세스 상태, 스케줄링 알고리즘 정리');

-- NT_02: 노트 수정: 제목 및 내용 변경
update note
set title = '운영체제 핵심 요약',
    content = '프로세스 상태 5단계, RR, SJF 스케줄링 비교',
    updated_at = current_timestamp
where note_id = 5;

-- NT_03: 노트 삭제: 특정 노트를 삭제
delete from note
where note_id = 5;