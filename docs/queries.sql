-- ============================================================
-- 学生管理系统 - 多表联查 & 聚合函数练习
-- ============================================================

USE student_management;


-- ============================================================
-- 一、多表联查 + 条件 + 分页
-- ============================================================

-- 1. 查学生 + 所在班级，按年级筛选，分页
SELECT
    s.student_no AS 学号,
    s.name       AS 姓名,
    s.phone      AS 电话,
    c.class_name AS 班级,
    c.grade      AS 年级
FROM student s
INNER JOIN class c ON s.class_id = c.id
WHERE s.status = 1
  AND c.grade = '2024级'
ORDER BY c.id, s.student_no
LIMIT 0, 10;


-- 2. 查成绩 + 学生 + 课程，按考试类型筛选，分页
SELECT
    s.name         AS 姓名,
    co.course_name AS 课程,
    sc.exam_type   AS 考试类型,
    sc.score       AS 分数
FROM score sc
INNER JOIN student      s  ON sc.student_id = s.id
INNER JOIN class_course cc ON sc.class_course_id = cc.id
INNER JOIN course       co ON cc.course_id = co.id
WHERE sc.exam_type = '期末'
  AND sc.score >= 60
ORDER BY sc.score DESC
LIMIT 0, 10;


-- 3. 查班级排课情况（班级 + 课程 + 教师）
SELECT
    cl.class_name  AS 班级,
    co.course_name AS 课程,
    u.real_name    AS 授课教师,
    cc.semester    AS 学期
FROM class_course cc
INNER JOIN class    cl ON cc.class_id  = cl.id
INNER JOIN course   co ON cc.course_id = co.id
INNER JOIN sys_user u  ON cc.teacher_id = u.id
WHERE cc.semester = '2024-2025-2'
ORDER BY cl.class_name;


-- ============================================================
-- 二、聚合函数（MAX / MIN / AVG / COUNT）+ WHERE
-- ============================================================

-- 4. 每门课程的最高分、最低分、平均分（只看期末）
SELECT
    co.course_name  AS 课程,
    COUNT(sc.id)    AS 考试人数,
    MAX(sc.score)   AS 最高分,
    MIN(sc.score)   AS 最低分,
    ROUND(AVG(sc.score), 1) AS 平均分
FROM score sc
INNER JOIN class_course cc ON sc.class_course_id = cc.id
INNER JOIN course       co ON cc.course_id = co.id
WHERE sc.exam_type = '期末'
GROUP BY co.id, co.course_name
ORDER BY 平均分 DESC;


-- 5. 每个班级的学生人数（只统计在读）
SELECT
    c.grade       AS 年级,
    c.class_name  AS 班级,
    COUNT(s.id)   AS 学生人数
FROM class c
LEFT JOIN student s ON c.id = s.class_id AND s.status = 1
GROUP BY c.id, c.grade, c.class_name
ORDER BY c.grade, c.class_name;


-- 6. 查分数不及格的学生及科目（期末 < 60）
SELECT
    s.name         AS 姓名,
    co.course_name AS 课程,
    sc.score       AS 分数
FROM score sc
INNER JOIN student      s  ON sc.student_id = s.id
INNER JOIN class_course cc ON sc.class_course_id = cc.id
INNER JOIN course       co ON cc.course_id = co.id
WHERE sc.exam_type = '期末'
  AND sc.score < 60
ORDER BY sc.score;
