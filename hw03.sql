SELECT region, SUM(COALESCE(amount), 0)
FROM sales
GROUP by region;


SELECT region, AVG(amount)
FROM sales
GROUP by region
HAVING COUNT(amount) > 0;


SELECT region, amount
FROM sales
WHERE amount > 0
ORDER by amount DESC
LIMIT 1;


SELECT COUNT(region) as total,
COUNT(amount) as nonNull
FROM sales;


SELECT region, amount
FROM sales
WHERE amount > (SELECT AVG(amount) FROM sales);

==========================================

CREATE TABLE students (
                         student_id SERIAL PRIMARY KEY,
                         first_name VARCHAR(50) NOT NULL,
                         last_name VARCHAR(50) NOT NULL,
                         birth_date DATE NOT NULL,
                         email VARCHAR(100) UNIQUE,
                         group_id INT NOT NULL
);

INSERT INTO students (first_name, last_name, birth_date, email, group_id) VALUES
('Abror','Mirzaev','2024-01-01','123@mail.ru',1),
('Sardor','Axmedov','2024-02-01','321@mail.ru',1),
('Abror','Mirzaev','2024-01-01','1234@mail.ru',1);


SELECT first_name || ' ' || last_name FROM students
GROUP by first_name, last_name
HAVING count(*) > 1;

DELETE FROM students s1
USING students s2
WHERE s1.first_name = s2.first_name
  AND s1.last_name = s2.last_name
  AND s1.student_id > s2.student_id;

==========================================

CREATE TABLE students (
   student_id INT PRIMARY KEY,
   full_name VARCHAR(100),
   age INT,
   group_id INT
);

CREATE TABLE groups (
   group_id INT PRIMARY KEY,
   group_name VARCHAR(50)
);

CREATE TABLE subjects (
   subject_id INT PRIMARY KEY,
   subject_name VARCHAR(50)
);

CREATE TABLE grades (
   grade_id INT PRIMARY KEY,
   student_id INT,
   subject_id INT,
   grade INT,
   FOREIGN KEY (student_id) REFERENCES students(student_id),
   FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

INSERT INTO students (student_id, full_name, age, group_id) VALUES
(1, 'Abror Mirzaev', 35, 1),
(2, 'Sarvar Gayupov', 31, 1),
(3, 'Sardor Axmedov', 30, 2),
(4, 'Islom Karimov', 29, 2),
(5, 'Aziza Azizova', 33, 3),
(6, 'Lola Axmedova', 36, 3);

INSERT INTO groups (group_id, group_name) VALUES
(1, 'Java'),
(2, 'SQL'),
(3, 'DevOps');

INSERT INTO subjects (subject_id, subject_name) VALUES
(1, 'OOP'),
(2, 'Queries'),
(3, 'Linux');

INSERT INTO grades (grade_id, student_id, subject_id, grade) VALUES
(1, 1, 1, 10),
(2, 2, 1, 8),
(3, 3, 2, 5),
(4, 5, 3, 8),
(5, 1, 2, 9),
(6, 1, 3, 9),
(7, 1, 3, 9);

SELECT count(*) FROM students;
SELECT ROUND(AVG(age), 2) AS average_age FROM students;
SELECT MIN(age) AS min_age, MAX(age) AS max_age FROM students;

SELECT count(*) FROM grades WHERE grade > 0;

SELECT groups.group_name, count(*) FROM students
JOIN groups ON students.group_id = groups.group_id
GROUP BY groups.group_name;

SELECT group_name, ROUND(AVG(age), 2) FROM students
JOIN groups ON students.group_id = groups.group_id
GROUP BY group_name;

SELECT group_name, ROUND(AVG(grade), 2) FROM grades
JOIN students
JOIN groups
ON students.group_id = groups.group_id
ON grades.student_id = students.student_id
GROUP BY group_name;

SELECT students.full_name, COUNT(DISTINCT grades.student_id) FROM grades
JOIN students ON grades.student_id = students.student_id
GROUP BY full_name
HAVING COUNT(DISTINCT subject_id) = (SELECT COUNT(subject_id) FROM subjects);

SELECT group_name FROM students
JOIN groups ON students.group_id = groups.group_id
GROUP BY group_name
HAVING COUNT(student_id) > 1

SELECT subjects.subject_name, ROUND(AVG(grades.grade), 2) FROM grades
JOIN subjects ON grades.subject_id = subjects.subject_id
GROUP BY subjects.subject_name
HAVING AVG(grades.grade) > 8

SELECT students.full_name, ROUND(AVG(grades.grade), 2) FROM grades
JOIN students ON grades.student_id = students.student_id
GROUP BY full_name
HAVING COUNT(DISTINCT subject_id) = (SELECT COUNT(subject_id) FROM subjects)
AND AVG(DISTINCT grades.grade) > 8.5;
