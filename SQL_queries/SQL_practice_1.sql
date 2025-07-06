/* f

following this tutorial
https://youtu.be/HXV3zeQKqGY?si=y8GDMQtMPWQmN70C

    MOST COMMMON DATATYPES
    INT                     WHOLE NUMBERS
    DECIMAL(M, N)           DECIMAL NUMBERS / EXACT VALUE
    VARCHAR(1)              STRING OF TEXT OF LENGTH 1
    BLOB                    BINARY LARGE OBJECT, STORES LARGE DATA
    DATE                    'YYYY-MM-DD'
    TIMESTAMP               'YYYY-MM-DD HH:MM:SS' USED FOR DOCUMENTATION
    
*/

/*
    CONNECT TO MYSQL THROUGH DOCKER:
    https://stackoverflow.com/questions/33001750/connect-to-mysql-in-a-docker-container-from-the-host

    mysql -h localhost -P 3306 --protocol=tcp -u root

    mysql -h 127.0.0.1 -P 3306 -u root
*/

-- tables

CREATE TABLE student (
    --student_id INT PRIMARY KEY,
    student_id INT,
    name VARCHAR(25),
    major VARCHAR(25),
    PRIMARY KEY(student_id)
);

-- delete tables
DROP TABLE student

-- next we gonna add a table for the student's GPA

ALTER TABLE student ADD gpa DECIMAL(3, 2);

-- how to delete a column

ALTER TABLE student DROP COLUMN gpa;

-- first you wanna create your database schema

-- now lets insert data into our database
-- 1:32:00
-- always specify the table's name whenever you're about
-- to input data into it
SELECT * FROM student;

INSERT INTO student VALUES(
    1, 'Jack', 'Biology', 1
);

INSERT INTO student VALUES(
    2, 'Kate', 'Sociology', 2
);

/*
    lets assume a student does not have a major
*/
SELECT * FROM student;
INSERT INTO student(student_id, name) VALUES(3, 'Jake');

-- lets finish it off

SELECT * FROM student;
INSERT INTO student VALUES(4, 'miguel', 'comp sci', 4);

INSERT INTO student VALUES(5, 'Cindy', 'Psychology', 5);

-- 1:40:40 NOT NULL
-- we dont want the student to necessarily have a name

-- what the tutorial wants is for me to drop students
-- and create a new table with the following schema

CREATE TABLE student (
    student_id INT,
    name VARCHAR(20) NOT NULL,
    major VARCHAR(20),
    PRIMARY KEY(student_id)
);

-- what you want to do in production
-- first make sure there are no NULL values or you will
-- get blocked out

SELECT COUNT(*) FROM student WHERE NAME IS NULL;

-- in case you were to get anything else but a 0

UPDATE student SET NAME = '' WHERE NAME IS NULL;

-- moving on

ALTER TABLE student
MODIFY COLUMN NAME VARCHAR(25) NOT NULL,
ALGORITHM=INPLACE,
LOCK=NONE;

SHOW WARNINGS;

/*
    this avoids table copying and long blocking, but note
    that MySQL may still ignore LOCK = NONE depending on 
    column type, indexes, or storage engine
*/

-- you can also use percona toolkit (copy as it is, even
-- if here the flags appear as comments)

pt-online-schema-change --alter "MODIFY NAME VARCAHR(25) NOT NULL" \
--host=localhost --user=youruser --password=yourpass \
--execute --no-check-replication-filters \
--alter-foreign-keys-method=auto \
D=WP_DB, t=student

-- lets change column 'major' to UNIQUE

SELECT COUNT(*) FROM student WHERE major IS NULL;

-- returns 1

UPDATE student SET major = '' WHERE major IS NULL;

-- 1 row affected

ALTER TABLE student
MODIFY COLUMN major VARCHAR(25) UNIQUE,
ALGORITHM=INPLACE,
LOCK=NONE;

SHOW WARNINGS;

-- now, in case the major column is left 
-- empty we can also do a "DEFAULT 'undecided'"
-- to specify, in case the column is left NULL,
-- instead it is filled with "undecided"
-- 1:44:52

ALTER TABLE student
MODIFY COLUMN major VARCHAR(25) DEFAULT 'undecided',
ALGORITHM=INPLACE,
LOCK=NONE;

SHOW WARNINGS;

-- now lets make it so PRIMARY KEY(student_id)

/*
    you gotta first verify the current primary key
    constraint on your table
*/

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'student' AND CONSTRAINT_NAME = 'PRIMARY';

-- it should return student_id as the primary key
-- since the PK is defined at the table level you
-- can drop it directly

ALTER TABLE student
DROP PRIMARY KEY,
ALGORITHM=INPLACE,
LOCK=NONE;
-- ALGIRHTM=INPLACE minimizes locking but may not work
-- if the table has certain dependencies

-- check for NULLs in student_id
SELECT COUNT(*) FROM student WHERE student_id IS NULL;

-- check for duplicates
SELECT student_id, COUNT(*)
FROM student
GROUP BY student_id
HAVING COUNT(*) > 1;

-- check for referencing tables
SELECT 
    TABLE_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.REFERENTIAL_CONTRAINTS
WHERE REFERENCED_TABLE_NAME = 'student';

-- if you get "lock wait timeout" increate the timeout
-- temporalily

SET SESSION innodb_wait_timeout = 120; -- 120 seconds

-- now lets turn student_id INT into
-- student_id INT AUTO_INCREMENT

-- 1:48:12