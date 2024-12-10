SET
	client_min_messages TO WARNING;

drop TABLE IF EXISTS prereq;

drop TABLE IF EXISTS time_slot;

drop TABLE IF EXISTS advisor;

drop TABLE IF EXISTS takes;

drop TABLE IF EXISTS student;

drop TABLE IF EXISTS teaches;

drop TABLE IF EXISTS section;

drop TABLE IF EXISTS instructor;

drop TABLE IF EXISTS course;

drop TABLE IF EXISTS department;

drop TABLE IF EXISTS classroom;

DROP TABLE IF EXISTS grade_points;

create table classroom (
	building varchar(15),
	room_number varchar(7),
	capacity numeric(4, 0),
	primary key (building, room_number)
);

create table department (
	dept_name varchar(20),
	building varchar(15),
	budget numeric(12, 2) check (budget > 0),
	primary key (dept_name)
);

create table course (
	course_id varchar(8),
	title varchar(50),
	dept_name varchar(20),
	credits numeric(2, 0) check (credits > 0),
	primary key (course_id),
	foreign key (dept_name) references department on delete
	set
		null
);

create table instructor (
	ID varchar(5),
	name varchar(20) not null,
	dept_name varchar(20),
	salary numeric(8, 2) check (salary > 29000),
	primary key (ID),
	foreign key (dept_name) references department on delete
	set
		null
);

create table section (
	course_id varchar(8),
	sec_id varchar(8),
	semester varchar(6) check (
		semester in ('Fall', 'Winter', 'Spring', 'Summer')
	),
	year numeric(4, 0) check (
		year > 1701
		and year < 2100
	),
	building varchar(15),
	room_number varchar(7),
	time_slot_id varchar(4),
	primary key (course_id, sec_id, semester, year),
	foreign key (course_id) references course on delete cascade,
	foreign key (building, room_number) references classroom on delete
	set
		null
);

create table teaches (
	ID varchar(5),
	course_id varchar(8),
	sec_id varchar(8),
	semester varchar(6),
	year numeric(4, 0),
	primary key (ID, course_id, sec_id, semester, year),
	foreign key (course_id, sec_id, semester, year) references section on delete cascade,
	foreign key (ID) references instructor on delete cascade
);

create table student (
	ID varchar(5),
	name varchar(20) not null,
	dept_name varchar(20),
	tot_cred numeric(3, 0) check (tot_cred >= 0),
	primary key (ID),
	foreign key (dept_name) references department on delete
	set
		null
);

create table takes (
	ID varchar(5),
	course_id varchar(8),
	sec_id varchar(8),
	semester varchar(6),
	year numeric(4, 0),
	grade varchar(2),
	primary key (ID, course_id, sec_id, semester, year),
	foreign key (course_id, sec_id, semester, year) references section on delete cascade,
	foreign key (ID) references student on delete cascade
);

CREATE TABLE grade_points (
	grade VARCHAR(2) PRIMARY KEY,
	points NUMERIC(3, 2)
);

create table advisor (
	s_ID varchar(5),
	i_ID varchar(5),
	primary key (s_ID),
	foreign key (i_ID) references instructor (ID) on delete
	set
		null,
		foreign key (s_ID) references student (ID) on delete cascade
);

create table time_slot (
	time_slot_id varchar(4),
	day varchar(1),
	start_hr numeric(2) check (
		start_hr >= 0
		and start_hr < 24
	),
	start_min numeric(2) check (
		start_min >= 0
		and start_min < 60
	),
	end_hr numeric(2) check (
		end_hr >= 0
		and end_hr < 24
	),
	end_min numeric(2) check (
		end_min >= 0
		and end_min < 60
	),
	primary key (time_slot_id, day, start_hr, start_min)
);

create table prereq (
	course_id varchar(8),
	prereq_id varchar(8),
	primary key (course_id, prereq_id),
	foreign key (course_id) references course on delete cascade,
	foreign key (prereq_id) references course
);

DELETE FROM
	grade_points;

INSERT INTO
	grade_points (grade, points)
VALUES
	('A', 4.0),
	('A-', 3.7),
	('B+', 3.3),
	('B', 3.0),
	('B-', 2.7),
	('C+', 2.3),
	('C', 2.0),
	('C-', 1.7),
	('D+', 1.3),
	('D', 1.0),
	('F', 0.0);

INSERT INTO
	department (dept_name, building, budget)
VALUES
	('Comp. Sci.', 'Watson', 500000.00);

INSERT INTO
	course (course_id, title, dept_name, credits)
VALUES
	(
		'CS101',
		'Introduction to Computer Science',
		'Comp. Sci.',
		3
	),
	('CS102', 'Data Structures', 'Comp. Sci.', 4);

INSERT INTO
	instructor (ID, name, dept_name, salary)
VALUES
	('I101', 'Einstein', 'Comp. Sci.', 80000.00);

INSERT INTO
	student (ID, name, dept_name, tot_cred)
VALUES
	('S101', 'Alice', 'Comp. Sci.', 30);

INSERT INTO
	classroom (building, room_number, capacity)
VALUES
	('Watson', '101', 50);

INSERT INTO
	section (
		course_id,
		sec_id,
		semester,
		year,
		building,
		room_number,
		time_slot_id
	)
VALUES
	(
		'CS101',
		'S1',
		'Fall',
		2009,
		'Watson',
		'101',
		'A1'
	);

INSERT INTO
	teaches (ID, course_id, sec_id, semester, year)
VALUES
	('I101', 'CS101', 'S1', 'Fall', 2009);

INSERT INTO
	takes (ID, course_id, sec_id, semester, year, grade)
VALUES
	('S101', 'CS101', 'S1', 'Fall', 2009, 'A');

INSERT INTO
	student (ID, name, dept_name, tot_cred)
VALUES
	('12345', 'Bob', 'Comp. Sci.', 40);

INSERT INTO
	takes (ID, course_id, sec_id, semester, year, grade)
VALUES
	('12345', 'CS101', 'S1', 'Fall', 2009, 'A');





-- a. Find the total grade-points earned by the student with ID 12345, across all courses taken by the student.
SELECT
	SUM(course.credits * grade_points.points) AS total_grade_points
FROM
	takes
	JOIN course ON takes.course_id = course.course_id
	JOIN grade_points ON takes.grade = grade_points.grade
WHERE
	takes.ID = '12345';

-- b. Find the grade-point average (GPA) for the above student, that is, the total grade-points 
-- divided by the total credits for the associated courses.
SELECT
	SUM(course.credits * grade_points.points) / SUM(course.credits) AS GPA
FROM
	takes
	JOIN course ON takes.course_id = course.course_id
	JOIN grade_points ON takes.grade = grade_points.grade
WHERE
	takes.ID = '12345';

-- c. Find the ID and the grade-point average of every student.
SELECT
	takes.ID,
	SUM(course.credits * grade_points.points) / SUM(course.credits) AS GPA
FROM
	takes
	JOIN course ON takes.course_id = course.course_id
	JOIN grade_points ON takes.grade = grade_points.grade
GROUP BY
	takes.ID;

RESET client_min_messages;