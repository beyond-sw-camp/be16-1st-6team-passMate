-- 회원가입: 더미 유저 10명 등록
insert into user (email, password, nickname, role, profile_image, job) values
('alice@example.com', 'hashed_pw_123', 'alice', 'USER', null, '개발자'),
('bob@example.com', 'hashed_pw_123', 'bob', 'USER', 'https://image.site/bob.png', '디자이너'),
('carol@example.com', 'hashed_pw_123', 'carol', 'USER', null, null),
('dave@example.com', 'hashed_pw_123', 'dave', 'USER', 'https://image.site/dave.png', '기획자'),
('eve@example.com', 'hashed_pw_123', 'eve', 'USER', null, '마케터'),
('frank@example.com', 'hashed_pw_123', 'frank', 'USER', null, null),
('grace@example.com', 'hashed_pw_123', 'grace', 'USER', 'https://image.site/grace.png', '디자이너'),
('heidi@example.com', 'hashed_pw_123', 'heidi', 'USER', null, '개발자'),
('ivan@example.com', 'hashed_pw_123', 'ivan', 'USER', null, null),
('judy@example.com', 'hashed_pw_123', 'judy', 'USER', 'https://image.site/judy.png', '기획자');

-- 회원가입: 일반 유저
insert into user (email, password, nickname, role, profile_image, job) values
('charlie@naver.com', 'hash_asdkj!as212', 'charlie', 'USER', 'https://image.site/bob.png', '개발자');

select * from user where email = 'charlie@naver.com';


-- 로그인: 사용자는 이메일, 비밀번호로 로그인한다.
select * from user;

select * from user 
where email = 'charlie@naver.com' 
	and password = 'hash_asdkj!as212';


-- 회원 탈퇴: 사용자가 계정을 삭제한다.
delete from user
where user_id = 10;

select * from user;
