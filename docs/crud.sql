-- ============================================================
-- 学生管理系统 - 简单增删改查练习
-- ============================================================

USE student_management;


-- ============================================================
-- 一、INSERT（插入数据）
-- ============================================================

-- 1. 新增一个班级
INSERT INTO class (class_name, grade, head_teacher_id, room, description)
VALUES ('人工233', '2023级', 6, 'C103', '人工智能学院人工智能专业');

-- 2. 新增一个学生（学号不可重复）
INSERT INTO student (student_no, name, gender, birthday, phone, class_id, enrollment_date, status)
VALUES ('20240306', '刘明轩', 1, '2005-06-15', '13900002001', 3, '2024-09-01', 1);

-- 3. 新增一条成绩记录
INSERT INTO score (student_id, class_course_id, score, exam_type)
VALUES (12, 1, 88.5, '期中');


-- ============================================================
-- 二、SELECT（查询数据）
-- ============================================================

-- 4. 查所有软件工程专业 2024 级的班级
SELECT id, class_name, grade, room
FROM class
WHERE class_name LIKE '软件%'
  AND grade = '2024级';

-- 5. 查某个学生的基本信息
SELECT student_no, name,
       CASE gender WHEN 1 THEN '男' WHEN 2 THEN '女' ELSE '未知' END AS 性别,
       birthday, phone
FROM student
WHERE student_no = '2024001';

-- 6. 查某门课程的所有期末成绩（学生 + 分数）
SELECT s.name, sc.score
FROM score sc
INNER JOIN student      s  ON sc.student_id = s.id
INNER JOIN class_course cc ON sc.class_course_id = cc.id
WHERE cc.course_id = 1
  AND sc.exam_type = '期末'
ORDER BY sc.score DESC;


-- ============================================================
-- 三、UPDATE（修改数据）
-- ============================================================

-- 7. 修改学生手机号
UPDATE student
SET phone = '13900003001'
WHERE student_no = '2024001';

-- 8. 修改某条成绩的分数
UPDATE score
SET score = 90.0
WHERE student_id = 3
  AND class_course_id = 1
  AND exam_type = '期末';


-- ============================================================
-- 四、DELETE（删除数据）
-- ============================================================

-- 9. 删除一条成绩记录
DELETE FROM score
WHERE student_id = 3
  AND class_course_id = 1
  AND exam_type = '期中';

-- 10. 学生休学（不真删，改状态为 0）
UPDATE student
SET status = 0
WHERE student_no = '2024005';
