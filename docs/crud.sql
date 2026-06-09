USE student_management;

-- 新增一个学生（学号不可重复）
INSERT INTO student (student_no, name, gender, birthday, phone, class_id, enrollment_date, status)
VALUES ('20250306', 'Reze', 1, '2005-06-15', '13900002001', 3, '2024-09-01', 1);

-- 查所有软件工程专业 2024 级的班级
SELECT id, class_name, grade, room
FROM class
WHERE class_name LIKE '软件%'
  AND grade = '2024级';

-- 查某个学生的基本信息
SELECT student_no, name,
       CASE gender WHEN 1 THEN '男' WHEN 2 THEN '女' ELSE '未知' END AS 性别,
       birthday, phone
FROM student
WHERE student_no = '2024001';

-- 修改学生手机号
UPDATE student
SET phone = '13900003001'
WHERE student_no = '2024001';

-- 删除一条成绩记录
DELETE FROM score
WHERE student_id = 3
  AND class_course_id = 1
  AND exam_type = '期中';
