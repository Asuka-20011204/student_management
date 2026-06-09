-- ============================================================
-- 班级名称重命名：软件工程1班 → 软件工程241
-- 规则：专业名 + 年级后两位 + 班级序号
-- ============================================================
USE student_management;

UPDATE class SET class_name = CONCAT(
    LEFT(class_name, CHAR_LENGTH(class_name) - 2),        -- 专业名（去掉末尾"X班"）
    LEFT(RIGHT(grade, 3), 2),                             -- 年级后两位：2024级→24
    SUBSTRING(class_name, CHAR_LENGTH(class_name) - 1, 1)  -- 班级序号：1
);

-- 验证
SELECT id, class_name, grade FROM class ORDER BY id;
