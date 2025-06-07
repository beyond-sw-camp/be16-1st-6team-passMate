
-- 회원
create table user (
    user_id bigint not null auto_increment primary key,
    email varchar(255) not null,
    nickname varchar(50) null,
    password varchar(255) not null,
    role enum('USER', 'ADMIN') not null,
    profile_image varchar(255) null,
    job varchar(255) null,
    created_at datetime null default current_timestamp,
    updated_at datetime null
);


-- 자격증 정보 관련 DDL.  ------------------------------------------------

-- 자격구분
create table qualification_type (
    qualification_type_id bigint not null auto_increment primary key,
    name varchar(255) not null
);

-- 직무분야
create table job_field (
    job_field_id bigint not null auto_increment primary key,
    qualification_type_id bigint not null,
    name varchar(255) not null,
    foreign key (qualification_type_id) references qualification_type(qualification_type_id) on delete cascade
);

-- 분류
create table category (
    category_id bigint not null auto_increment primary key,
    job_field_id bigint not null,
    name varchar(255) not null,
    foreign key (job_field_id) references job_field(job_field_id) on delete cascade
);

-- 기관
create table organization (
    organization_id bigint not null auto_increment primary key,
    name varchar(255) not null,
    phone varchar(255) null,
    email varchar(255) null,
    homepage varchar(255) null
);


-- 시험 종목
create table exam_subject (
    exam_subject_id bigint not null auto_increment primary key,
    category_id bigint not null,
    organization_id bigint not null,
    name varchar(255) not null,
    description text null,
    foreign key (category_id) references category(category_id)  on delete cascade,
    foreign key (organization_id) references organization(organization_id)
);


-- 시험 정보
create table exam_info (
    exam_info_id bigint not null auto_increment primary key,
    exam_subject_id bigint not null,
    year date not null,
    session bigint not null,
    applicants int null,
    passer_cnt int null,
    pass_ratio decimal(5, 2) null,
    foreign key (exam_subject_id) references exam_subject(exam_subject_id) on delete cascade
);

-- 시험 일정
create table exam_schedule (
    exam_schedule_id bigint not null auto_increment primary key,
    exam_info_id bigint not null,
    exam_type varchar(50) not null,
    apply_start date not null,
    apply_end date not null,
    exam_date date not null,
    result_date date not null,
    foreign key (exam_info_id) references exam_info(exam_info_id) on delete cascade
);

-- 문제
create table question (
    question_id bigint not null auto_increment primary key,
    content varchar(255) not null,
    image_url varchar(255) not null,
    answer varchar(255) not null
);

-- 기출문제
create table past_exam (
    past_exam_id bigint not null auto_increment primary key,
    exam_subject_id bigint not null,
    exam_info_id bigint not null,
    foreign key (exam_subject_id) references exam_subject(exam_subject_id) on delete cascade,
    foreign key (exam_info_id) references exam_info(exam_info_id) on delete cascade
);

-- 시험
create table exam (
    exam_id bigint not null auto_increment primary key,
    question_id bigint not null,
    past_exam_id bigint not null,
    foreign key (question_id) references question(question_id),
    foreign key (past_exam_id) references past_exam(past_exam_id)
);

-- 시험 관련 비용
create table exam_fee (
    exam_fee_id bigint not null auto_increment primary key,
    exam_subject_id bigint not null,
    fee_type enum('발급', '재발급', '필기', '실기') not null,
    amount int not null,
    foreign key (exam_subject_id) references exam_subject(exam_subject_id) on delete cascade
);

-- 커리큘럼 관련 DDL. ----------------------------------------------------

-- 커리큘럼
create table curriculum (
    curriculum_id bigint not null auto_increment primary key,
    user_id bigint not null,
    exam_subject_id bigint null,
    name varchar(255) not null,
    created_at datetime not null default current_timestamp,
    updated_at datetime null DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (exam_subject_id) references exam_subject(exam_subject_id) on delete set null
);

-- 일정
create table event (
    event_id bigint not null auto_increment primary key,
    user_id bigint not null,
    exam_subject_id bigint null,
    title varchar(255) not null,
    subjects varchar(255) null,
    start_date date not null,
    end_date date not null,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (exam_subject_id) references exam_subject(exam_subject_id) on delete set null
);

-- 커리큘럼_일정
create table curriculum_event (
    curriculum_event_id bigint not null auto_increment primary key,
    curriculum_id bigint not null,
    event_id bigint not null,
    foreign key (curriculum_id) references curriculum(curriculum_id) on delete cascade,
    foreign key (event_id) references event(event_id) on delete cascade
);

-- 종목상세
create table subject_detail (
    subject_detail_id bigint not null auto_increment primary key,
    event_id bigint not null,
    name varchar(255) null,
    foreign key (event_id) references event(event_id) on delete cascade
);

-- 학습 반복
create table repetition (
    repetition_id bigint not null auto_increment primary key,
    event_id bigint not null,
    repeat_interval enum('DAILY', 'WEEKLY', 'MONTHLY') not null,
    interval_times int not null default 1,
    repeat_times int not null default 1,
    foreign key (event_id) references event(event_id) on delete cascade
);

-- 노트
create table note (
    note_id bigint not null auto_increment primary key,
    user_id bigint not null,
    event_id bigint not null,
    title varchar(255) null,
    content text null,
    created_at datetime not null default current_timestamp,
    updated_at datetime null DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (event_id) references event(event_id) on delete cascade
);

-- 할 일
create table task (
    task_id bigint not null auto_increment primary key,
    user_id bigint not null,
    content varchar(500) not null,
    is_done boolean null default false,
    task_date datetime not null,
    created_at datetime not null default current_timestamp,
    updated_at datetime null DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    foreign key (user_id) references user(user_id) on delete cascade
);

-- 커리큘럼_노트
create table curriculum_note (
    curriculum_note_id bigint not null auto_increment primary key,
    curriculum_id bigint not null,
    note_id bigint not null,
    foreign key (curriculum_id) references curriculum(curriculum_id) on delete cascade,
    foreign key (note_id) references note(note_id) on delete cascade
);

-- 커리큘럼_할일
create table curriculum_task (
    curriculum_task_id bigint not null auto_increment primary key,
    curriculum_id bigint not null,
    task_id bigint not null,
    foreign key (curriculum_id) references curriculum(curriculum_id) on delete cascade,
    foreign key (task_id) references task(task_id) on delete cascade
);

-- 판매 및 구매 관련 DDL. ----------------------------------

-- 판매등록
create table curriculum_sale (
    curriculum_sale_id bigint not null auto_increment primary key,
    seller_id bigint not null,
    curriculum_id bigint not null,
    exam_subject_id bigint not null,
    title varchar(255) not null,
    price int not null,
    thumbnail_url varchar(255) null,
    description text null,
    is_seen boolean not null default false,
    created_at datetime not null default current_timestamp,
    updated_at datetime null DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    foreign key (seller_id) references user(user_id) on delete cascade,
    foreign key (curriculum_id) references curriculum(curriculum_id) on delete cascade,
    foreign key (exam_subject_id) references exam_subject(exam_subject_id)
);

-- 커리큘럼_자료
create table material (
    material_id bigint not null auto_increment primary key,
    user_id bigint not null,
    sale_id bigint not null,
    title varchar(100) not null,
    file_url varchar(255) not null,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (sale_id) references curriculum_sale(curriculum_sale_id) on delete cascade
);

-- 좋아요
create table curriculum_like (
    like_id bigint not null auto_increment primary key,
    user_id bigint not null,
    curriculum_sale_id bigint not null,
    created_at datetime not null default current_timestamp,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (curriculum_sale_id) references curriculum_sale(curriculum_sale_id) on delete cascade
);

-- 장바구니
create table cart (
    cart_id bigint not null auto_increment primary key,
    user_id bigint not null,
    curriculum_sale_id bigint not null,
    created_at datetime not null default current_timestamp,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (curriculum_sale_id) references curriculum_sale(curriculum_sale_id) on delete cascade
);

-- 즐겨찾기
create table favorite (
    favorite_id bigint not null auto_increment primary key,
    user_id bigint not null,
    favorite_user_id bigint not null,
    created_at datetime not null default current_timestamp,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (favorite_user_id) references user(user_id) on delete cascade
);

-- 결제 관련 DDL. -------------------------------------------

-- 결제수단
create table method (
    method_id bigint not null auto_increment primary key,
    user_id bigint not null,
    type varchar(50) not null,
    account varchar(255) not null,
    foreign key (user_id) references user(user_id) on delete cascade
);

-- 결제내역
create table payment (
    payment_id bigint not null auto_increment primary key,
    user_id bigint not null,
    curriculum_sale_id bigint not null,
    method_id bigint not null,
    status enum('STANBY', 'IN_PROGRESS', 'COMPLETE') not null,
    date datetime null default current_timestamp,
    confirm boolean not null default false,
    foreign key (user_id) references user(user_id) on delete cascade,
    foreign key (curriculum_sale_id) references curriculum_sale(curriculum_sale_id),
    foreign key (method_id) references method(method_id)
);

-- 정산계좌
create table settlement_account (
    settlement_account_id bigint not null auto_increment primary key,
    user_id bigint not null,
    bank varchar(50) null,
    account_number varchar(500) null,
    foreign key (user_id) references user(user_id) on delete cascade
);

-- 정산내역
create table settlement (
    settlement_id bigint not null auto_increment primary key,
    settlement_account_id bigint not null,
    payment_id bigint not null,
    settlement_amount int null,
    settlement_date datetime null,
    is_completed boolean not null default false,
    foreign key (settlement_account_id) references settlement_account(settlement_account_id) on delete cascade,
    foreign key (payment_id) references payment(payment_id)
);

-- 그 외 DDL. ------------------------------------------

-- 쪽지
create table message (
    message_id bigint not null auto_increment primary key,
    sender_id bigint not null,
    receiver_id bigint not null,
    contents varchar(255) not null,
    is_seen boolean not null default false,
    read_at datetime null,
    foreign key (sender_id) references user(user_id) on delete cascade,
    foreign key (receiver_id) references user(user_id) on delete cascade
);


-- 알림 기록
create table notification (
    notification_id bigint not null auto_increment primary key,
    user_id bigint not null,
    content varchar(255) not null,
    is_seen boolean not null default false,
    created_at datetime not null default current_timestamp,
    foreign key (user_id) references user(user_id) on delete cascade
);