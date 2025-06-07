create database passmate;
use passmate;

CREATE TABLE `notification` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`content` VARCHAR(255) NOT NULL,
	`is_seen` BOOLEAN NOT NULL DEFAULT FALSE,
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `material_logs` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`material_id` BIGINT NOT NULL,
	`user_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`is_open` BOOLEAN NOT NULL,
	`opend_at` DATETIME NULL
);

CREATE TABLE `exam_schedule` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`exam_info_id` BIGINT NOT NULL,
	`exam_type` ENUM('필기', '실기', '면접') NOT NULL,
	`apply_start` DATE NOT NULL,
	`apply_end` DATE NOT NULL,
	`exam_date` DATE NOT NULL,
	`result_date` DATE NOT NULL
);

CREATE TABLE `cart` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`curriculum_sale_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `favorite` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`favorite_user_id` BIGINT NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `calendar_task` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`calendar_id` BIGINT NOT NULL,
	`task_id` BIGINT NOT NULL
);

CREATE TABLE `adjustment_account` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`bank` varchar(50) NULL,
	`account_number` varchar(500) NULL
);

CREATE TABLE `job_field` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`qualification_type_id` BIGINT NOT NULL,
	`name` VARCHAR(255) NOT NULL
);

CREATE TABLE `task` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`content` TEXT NOT NULL,
	`is_done` BOOLEAN NULL DEFAULT FALSE,
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp,
	`updated_at` DATETIME NULL,
	`task_date` DATETIME NOT NULL
);

CREATE TABLE `curriculum_sale` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`seller_id` BIGINT NOT NULL,
	`curriculum_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`title` VARCHAR(255) NOT NULL,
	`price` INT NOT NULL,
	`thumbnail` VARCHAR(255) NULL,
	`description` TEXT NULL,
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME NULL
);

CREATE TABLE `exam` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`question_id` BIGINT NOT NULL,
	`Key` BIGINT NOT NULL
);

CREATE TABLE `qualification_type` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`name` VARCHAR(255) NOT NULL
);

CREATE TABLE `calendar_note` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`calendar_id` BIGINT NOT NULL,
	`note_id` BIGINT NOT NULL
);

CREATE TABLE `exam_info` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`certificate_id` BIGINT NOT NULL,
	`year` DATE NOT NULL,
	`session` BIGINT NOT NULL,
	`applicant_cnt` INT NULL,
	`passer_cnt` INT NULL,
	`pass_ratio` DOUBLE NULL
);

CREATE TABLE `like` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`sale_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `payment` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`curriculum_sale_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`payment` ENUM('카드', '계좌', '간편결제') NOT NULL,
	`status` ENUM('대기', '진행', '완료') NOT NULL,
	`date` DATETIME NULL DEFAULT current_timestamp,
	`is_opened` BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE `calendar_event` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`calendar_id` BIGINT NOT NULL,
	`event_id` BIGINT NOT NULL
);

CREATE TABLE `note` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`event_id` BIGINT NOT NULL,
	`title` VARCHAR(255) NULL,
	`content` TEXT NULL,
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp,
	`updated_at` DATETIME NULL
);

CREATE TABLE `user` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`email` varchar(255) NULL,
	`nickname` varchar(50) NULL,
	`passworde` varchar(255) NULL,
	`createdAt` DATETIME NULL,
	`updatedAt` DATETIME NULL
);

CREATE TABLE `event` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`subjects` VARCHAR(255) NULL,
	`start_date` DATETIME NOT NULL,
	`end_date` DATETIME NOT NULL,
	`title` VARCHAR(255) NOT NULL
);

CREATE TABLE `past_paper` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`certificate_id` BIGINT NOT NULL,
	`exam_info_id` BIGINT NOT NULL
);

CREATE TABLE `material` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`sale_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`title` VARCHAR(100) NOT NULL,
	`file_url` VARCHAR(255) NOT NULL
);

CREATE TABLE `repeat` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`certificate_id` BIGINT NOT NULL,
	`repeat_interval` ENUM('daily', 'weekly', 'monthly') NOT NULL,
	`interval_times` INT NOT NULL DEFAULT 1,
	`repeat_times` INT NOT NULL DEFAULT 1
);

CREATE TABLE `question` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`question_text` VARCHAR(255) NOT NULL,
	`image_path` VARCHAR(255) NOT NULL,
	`answer` VARCHAR(255) NOT NULL
);

CREATE TABLE `adjustment` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`account_id` BIGINT NOT NULL,
	`payment_id` BIGINT NOT NULL,
	`adjusted_amount` INT NULL,
	`adjusted_date` DATETIME NULL
);

CREATE TABLE `category` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`job_field_id` BIGINT NOT NULL,
	`name` VARCHAR(255) NOT NULL
);

CREATE TABLE `message` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`sender_id` BIGINT NOT NULL,
	`receiver_id` BIGINT NOT NULL,
	`contents` VARCHAR(255) NOT NULL,
	`is_seen` BOOLEAN NOT NULL DEFAULT FALSE,
	`read_at` DATETIME NULL
);

CREATE TABLE `curriculum` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`user_id` BIGINT NOT NULL,
	`certificate_id` BIGINT NOT NULL,
	`name` VARCHAR(50) NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT current_timestamp,
	`updated_at` DATETIME NULL
);

CREATE TABLE `organization` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`name` VARCHAR(255) NOT NULL,
	`tlno` VARCHAR(255) NULL,
	`email` VARCHAR(255) NULL,
	`url` VARCHAR(255) NULL
);

CREATE TABLE `certificate` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`category_id` BIGINT NOT NULL,
	`organization_id` BIGINT NOT NULL,
	`name` VARCHAR(255) NOT NULL,
	`description` TEXT NULL
);

CREATE TABLE `exam_fee` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`certificate_id` BIGINT NOT NULL,
	`fee_type` ENUM('필기', '실기', '면접', '발급', '재발급') NOT NULL,
	`fee` INT NOT NULL
);

CREATE TABLE `subject_detail` (
	`id` BIGINT NOT NULL primary key auto_increment,
	`event_id` BIGINT NOT NULL,
	`name` VARCHAR(255) NULL
);

ALTER TABLE
	`notification`
ADD
	CONSTRAINT `FK_user_TO_notification_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`material_logs`
ADD
	CONSTRAINT `FK_material_TO_material_logs_1` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`);

ALTER TABLE
	`material_logs`
ADD
	CONSTRAINT `FK_material_TO_material_logs_2` FOREIGN KEY (`user_id`) REFERENCES `material` (`id`);

ALTER TABLE
	`material_logs`
ADD
	CONSTRAINT `FK_material_TO_material_logs_3` FOREIGN KEY (`certificate_id`) REFERENCES `material` (`id`);

ALTER TABLE
	`exam_schedule`
ADD
	CONSTRAINT `FK_exam_info_TO_exam_schedule_1` FOREIGN KEY (`exam_info_id`) REFERENCES `exam_info` (`id`);

ALTER TABLE
	`cart`
ADD
	CONSTRAINT `FK_user_TO_cart_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`cart`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_cart_1` FOREIGN KEY (`curriculum_sale_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`cart`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_cart_2` FOREIGN KEY (`certificate_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`favorite`
ADD
	CONSTRAINT `FK_user_TO_favorite_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`calendar_task`
ADD
	CONSTRAINT `FK_curriculum_TO_calendar_task_1` FOREIGN KEY (`calendar_id`) REFERENCES `curriculum` (`id`);

ALTER TABLE
	`calendar_task`
ADD
	CONSTRAINT `FK_task_TO_calendar_task_1` FOREIGN KEY (`task_id`) REFERENCES `task` (`id`);

ALTER TABLE
	`adjustment_account`
ADD
	CONSTRAINT `FK_user_TO_adjustment_account_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`job_field`
ADD
	CONSTRAINT `FK_qualification_type_TO_job_field_1` FOREIGN KEY (`qualification_type_id`) REFERENCES `qualification_type` (`id`);

ALTER TABLE
	`task`
ADD
	CONSTRAINT `FK_user_TO_task_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`curriculum_sale`
ADD
	CONSTRAINT `FK_user_TO_curriculum_sale_1` FOREIGN KEY (`seller_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`curriculum_sale`
ADD
	CONSTRAINT `FK_curriculum_TO_curriculum_sale_1` FOREIGN KEY (`curriculum_id`) REFERENCES `curriculum` (`id`);

ALTER TABLE
	`curriculum_sale`
ADD
	CONSTRAINT `FK_certificate_TO_curriculum_sale_1` FOREIGN KEY (`certificate_id`) REFERENCES `certificate` (`id`);

ALTER TABLE
	`exam`
ADD
	CONSTRAINT `FK_question_TO_exam_1` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`);

ALTER TABLE
	`exam`
ADD
	CONSTRAINT `FK_past_paper_TO_exam_1` FOREIGN KEY (`Key`) REFERENCES `past_paper` (`id`);

ALTER TABLE
	`calendar_note`
ADD
	CONSTRAINT `FK_curriculum_TO_calendar_note_1` FOREIGN KEY (`calendar_id`) REFERENCES `curriculum` (`id`);

ALTER TABLE
	`calendar_note`
ADD
	CONSTRAINT `FK_note_TO_calendar_note_1` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`);

ALTER TABLE
	`exam_info`
ADD
	CONSTRAINT `FK_certificate_TO_exam_info_1` FOREIGN KEY (`certificate_id`) REFERENCES `certificate` (`id`);

ALTER TABLE
	`like`
ADD
	CONSTRAINT `FK_user_TO_like_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`like`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_like_1` FOREIGN KEY (`sale_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`like`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_like_2` FOREIGN KEY (`certificate_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`payment`
ADD
	CONSTRAINT `FK_user_TO_payment_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`payment`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_payment_1` FOREIGN KEY (`curriculum_sale_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`payment`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_payment_2` FOREIGN KEY (`certificate_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`calendar_event`
ADD
	CONSTRAINT `FK_curriculum_TO_calendar_event_1` FOREIGN KEY (`calendar_id`) REFERENCES `curriculum` (`id`);

ALTER TABLE
	`calendar_event`
ADD
	CONSTRAINT `FK_event_TO_calendar_event_1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE
	`note`
ADD
	CONSTRAINT `FK_user_TO_note_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`note`
ADD
	CONSTRAINT `FK_event_TO_note_1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE
	`event`
ADD
	CONSTRAINT `FK_user_TO_event_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`event`
ADD
	CONSTRAINT `FK_certificate_TO_event_1` FOREIGN KEY (`certificate_id`) REFERENCES `certificate` (`id`);

ALTER TABLE
	`past_paper`
ADD
	CONSTRAINT `FK_certificate_TO_past_paper_1` FOREIGN KEY (`certificate_id`) REFERENCES `certificate` (`id`);

ALTER TABLE
	`past_paper`
ADD
	CONSTRAINT `FK_exam_info_TO_past_paper_1` FOREIGN KEY (`exam_info_id`) REFERENCES `exam_info` (`id`);

ALTER TABLE
	`material`
ADD
	CONSTRAINT `FK_user_TO_material_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`material`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_material_1` FOREIGN KEY (`sale_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`material`
ADD
	CONSTRAINT `FK_curriculum_sale_TO_material_2` FOREIGN KEY (`certificate_id`) REFERENCES `curriculum_sale` (`id`);

ALTER TABLE
	`repeat`
ADD
	CONSTRAINT `FK_event_TO_repeat_2` FOREIGN KEY (`certificate_id`) REFERENCES `event` (`id`);

ALTER TABLE
	`adjustment`
ADD
	CONSTRAINT `FK_adjustment_account_TO_adjustment_1` FOREIGN KEY (`account_id`) REFERENCES `adjustment_account` (`id`);

ALTER TABLE
	`adjustment`
ADD
	CONSTRAINT `FK_payment_TO_adjustment_1` FOREIGN KEY (`payment_id`) REFERENCES `payment` (`id`);

ALTER TABLE
	`category`
ADD
	CONSTRAINT `FK_job_field_TO_category_1` FOREIGN KEY (`job_field_id`) REFERENCES `job_field` (`id`);

ALTER TABLE
	`message`
ADD
	CONSTRAINT `FK_user_TO_message_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`curriculum`
ADD
	CONSTRAINT `FK_user_TO_curriculum_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE
	`curriculum`
ADD
	CONSTRAINT `FK_certificate_TO_curriculum_1` FOREIGN KEY (`certificate_id`) REFERENCES `certificate` (`id`);

ALTER TABLE
	`certificate`
ADD
	CONSTRAINT `FK_category_TO_certificate_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

ALTER TABLE
	`certificate`
ADD
	CONSTRAINT `FK_organization_TO_certificate_1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`);

ALTER TABLE
	`exam_fee`
ADD
	CONSTRAINT `FK_certificate_TO_exam_fee_1` FOREIGN KEY (`certificate_id`) REFERENCES `certificate` (`id`);

ALTER TABLE
	`subject_detail`
ADD
	CONSTRAINT `FK_event_TO_subject_detail_1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);