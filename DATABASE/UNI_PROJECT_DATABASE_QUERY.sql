create database chatbot_personalization_engine;
/* First table for USER*/
create table users( user_id int primary key, user_name varchar(100), user_password varchar(255), user_email varchar(100) unique, user_role varchar(20));
/* Second  table for user_preferences*/
create table user_preferences(reference_id int primary key, user_id int, language varchar(50), favorite_topics varchar(255), chat_style varchar(50),foreign key(user_id) references users(user_id));
/* Third table for chat_sessions*/
create table chat_sessions(session_id int primary key, user_id int, start_time datetime, end_time datetime,foreign key(user_id) references users(user_id));
/* Four able for chat_messages*/
create table chat_messages( message_id int primary key,session_id int,message_text text,sender varchar(20),message_time datetime,foreign key(session_id) references chat_sessions(session_id));
/* Fifth table for interaction_history*/
create table interaction_history(interaction_id int primary key,user_id int,topic varchar(100),interaction_type varchar(50),date_time datetime,foreign key(user_id) references users(user_id));
/* Sixth table for personalization_rules*/
create table personalization_rules(rule_id int primary key,rule_type varchar(50),preference_link int,response_format varchar(100),foreign key(preference_link) references user_preferences(reference_id));
/* Seventh table for feedback*/
create table feedback(feedback_id int primary key,user_id int,rating int,comment text,date datetime,foreign key(user_id) references users(user_id));
/* Seventh table for system_reports*/
create table system_reports(report_id int primary key,report_type varchar(50),generated_date datetime,description text);
/*users table data*/
/*insert into users values(1,'jawad ahmed','jawad123','jawad@gmail.com','admin');*/
/*insert into users values(2,'ali khan','khan786','ali.k@yahoo.com','standard');*/
/*insert into users values(3,'sara malik','sara_pass','sara.m@hotmail.com','standard');
insert into users values(4,'bilal hassan','bilal2025','bilal.h@gmail.com','standard');
insert into users values(5,'usman ghani','ghani99','usman.g@outlook.com','moderator');*/
/*user_preferences table data */
/*insert into user_preferences values(101,1,'english','python, ai, logic','formal');
insert into user_preferences values(102,2,'urdu','cricket, politics','casual');
insert into user_preferences values(103,3,'english','movies, music','friendly');
insert into user_preferences values(104,4,'english','tech, gaming','short');
insert into user_preferences values(105,5,'urdu','news, sports','detailed');*/
/* 3. chat_sessions table data */
/*insert into chat_sessions values(501,1,'2025-11-17 10:00:00','2025-11-17 10:20:00');*/
/*insert into chat_sessions values(502,2,'2025-11-18 09:15:00','2025-11-18 09:30:00');*/
/*insert into chat_sessions values(503,3,'2025-11-18 14:00:00','2025-11-18 14:45:00');*/
/*insert into chat_sessions values(504,1,'2025-11-19 11:30:00','2025-11-19 11:40:00');*/
/*insert into chat_sessions values(505,4,'2025-11-20 16:00:00','2025-11-20 16:10:00');*/
/*chat_messages table data */
/*
insert into chat_messages values(1001,501,'hello how are you','user','2025-11-17 10:00:05');
insert into chat_messages values(1002,501,'i am fine jawad','bot','2025-11-17 10:00:10');
insert into chat_messages values(1003,502,'who won the match','user','2025-11-18 09:16:00');
insert into chat_messages values(1004,503,'suggest a good movie','user','2025-11-18 14:05:00');
insert into chat_messages values(1005,505,'pc requirements for gta 6','user','2025-11-20 16:01:00');
*/
/*interaction_history table data */
/*
insert into interaction_history values(201,1,'python coding','query','2025-11-17 10:15:00');
insert into interaction_history values(202,2,'cricket score','query','2025-11-18 09:20:00');
insert into interaction_history values(203,3,'action movies','recommendation','2025-11-18 14:10:00');
insert into interaction_history values(204,1,'database errors','troubleshoot','2025-11-19 11:35:00');
*/
/*personalization_rules table data */
/*
insert into personalization_rules values(301,'tone_match',101,'use_technical_terms');
insert into personalization_rules values(302,'language_switch',102,'reply_in_roman_urdu');
insert into personalization_rules values(303,'interest_filter',103,'show_netflix_links');
insert into personalization_rules values(305,'detail_level',105,'explain_with_examples');
*/
/*feedback table data */
/*
insert into feedback values(401,1,5,'excellent logic answers','2025-11-17 10:25:00');
insert into feedback values(402,2,4,'good but slow','2025-11-18 09:35:00');
insert into feedback values(403,3,5,'loved the movie list','2025-11-18 14:50:00');
insert into feedback values(404,1,3,'sometimes it gets stuck','2025-11-19 11:45:00');
insert into feedback values(405,4,4,'gaming info was correct','2025-11-20 16:15:00');
*/
/*system_reports table data */
/*
insert into system_reports values(601,'daily_usage','2025-11-17 23:59:00','total 15 active sessions');
insert into system_reports values(602,'error_log','2025-11-18 12:00:00','timeout error in session 502');
insert into system_reports values(603,'user_growth','2025-11-19 09:00:00','new user registration count 3');
insert into system_reports values(604,'feedback_summary','2025-11-20 20:00:00','average rating 4.2 stars');
insert into system_reports values(605,'performance','2025-11-21 08:00:00','database latency normal');
*/
/* 
testing database
checking user style before replying
select language, chat_style from user_preferences where user_id=1;

loading past conversation history for context
select m.message_text, m.sender, m.message_time 
from chat_messages as m join 
chat_sessions as s on 
m.session_id=s.session_id 
where s.user_id=1 
order by m.message_time desc;

looking for specific personalization rules
select r.rule_type, r.response_format 
from personalization_rules as r 
join user_preferences as p on r.preference_link=p.reference_id 
where p.user_id=3;

view to quickly see bad feedback for admin 
create view low_rated_feedback as select u.user_name, f.rating, f.comment 
from users as u join feedback as f 
on u.user_id=f.user_id 
where f.rating < 4;

admin checks the view
select * from low_rated_feedback;

admin report on most active users
select u.user_name, count(s.session_id) as total_sessions 
from users as u 
join chat_sessions as s on u.user_id=s.user_id 
group by u.user_name;

admin searching for users interested in python
select user_id, topic, date_time 
from interaction_history 
where topic like '%python%';

speed up login process
create index idx_login_email on users(user_email);

speed up loading chat history
create index idx_session_time on chat_sessions(start_time);

speed up finding messages in a session 
create index idx_message_session on chat_messages(session_id);

system maintenance removing empty sessions
delete from chat_sessions 
where session_id not in (select distinct session_id from chat_messages);

for let see admin which users have chatted recently
create view active_sessions_view as select u.user_name, s.start_time, s.end_time 
from users as u join 
chat_sessions as s on u.user_id = s.user_id 
where s.start_time >= current_date();

Connects Users,Sessions,Messages to see who said what
select u.user_name, s.session_id, m.message_text 
from users as u inner join 
chat_sessions as s on 
u.user_id = s.user_id 
inner join chat_messages as m on 
s.session_id = m.session_id;

Making  searching for specific topics fast
create index idx_history_topic on interaction_history(topic);

disable foreign key check to allow deletion
set foreign_key_checks=0;

deleting old data from user
delete from users;

inserting users with encrypted passwords for addinng encrytion
insert into users values(1,'jawad ahmed',sha2('jawad123',256),'jawad@gmail.com','admin');
insert into users values(2,'ali khan',sha2('khan786',256),'ali.k@yahoo.com','standard');
insert into users values(3,'sara malik',sha2('sara_pass',256),'sara.m@hotmail.com','standard');
insert into users values(4,'bilal hassan',sha2('bilal2025',256),'bilal.h@gmail.com','standard');
insert into users values(5,'usman ghani',sha2('ghani99',256),'usman.g@outlook.com','moderator');

re-enable foreign key check
set foreign_key_checks=1;

for chatbot taking input and convert to encrypted form for perfect match
select user_id, user_name, user_role 
from users 
where user_email='jawad@gmail.com' 
and user_password=sha2('jawad123',256);

Validation for Feedback to make sure  Rating range  is under 1 to 5
alter table feedback add constraint check_rating_range check (rating >= 1 and rating <= 5);

Validation for Messages that text cannot be empty
alter table chat_messages add constraint check_message_content check (length(trim(message_text)) > 0);

for further improvement in database for keep database clean
alter table chat_messages add constraint check_sender_type check (sender in ('user', 'bot'));

alter table users add constraint check_user_role check (user_role in ('admin', 'standard', 'moderator'));
*/



