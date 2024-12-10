drop table prereq;

drop table time_slot;

drop table advisor;

drop table takes;

drop table student;

drop table teaches;

drop table section;

drop table instructor;

drop table course;

drop table department;

drop table classroom;

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








-- a. Find the titles of courses in the Comp. Sci. department that have 3 credits.
SELECT
	title
FROM
	course
WHERE
	dept_name = 'Comp. Sci.'
	AND credits = 3;




-- b. Find the IDs of all students who were taught by an instructor named Einstein; make sure there are no duplicates in the result.
SELECT
	DISTINCT takes.ID
FROM
	takes
	JOIN teaches USING (course_id, sec_id, semester, year)
	JOIN instructor USING (ID)
WHERE
	instructor.name = 'Einstein';



-- c. Find the highest salary of any instructor.
SELECT
	MAX(salary) AS highest_salary
FROM
	instructor;


-- d. Find all instructors earning the highest salary (there may be more than one with the same salary).
SELECT
	ID,
	name,
	salary
FROM
	instructor
WHERE
	salary = (
		SELECT
			MAX(salary)
		FROM
			instructor
	);

-- e. Find the enrollment of each section that was offered in Autumn 2009.
SELECT
	course_id,
	sec_id,
	COUNT(ID) AS enrollment
FROM
	takes
WHERE
	semester = 'Fall'
	AND year = 2009

-- The GROUP BY course_id, sec_id ensures that the enrollment count is calculated for each unique section.
GROUP BY 
	course_id,
	sec_id;

-- f. Find the maximum enrollment, across all sections, in Autumn 2009.
SELECT
	MAX(enrollment) AS max_enrollment
FROM
	(
		SELECT
			COUNT(ID) AS enrollment
		FROM
			takes
		WHERE
			semester = 'Fall'
			AND year = 2009
		GROUP BY
			course_id,
			sec_id
	) AS section_enrollments;


-- g. Find the sections that had the maximum enrollment in Autumn 2009.
WITH section_enrollments AS (
	SELECT
		course_id,
		sec_id,
		COUNT(ID) AS enrollment
	FROM
		takes
	WHERE
		semester = 'Fall'
		AND year = 2009
	GROUP BY
		course_id,
		sec_id
)
SELECT
	course_id,
	sec_id
FROM
	section_enrollments
WHERE
	enrollment = (
		SELECT
			MAX(enrollment)
		FROM
			section_enrollments
	);