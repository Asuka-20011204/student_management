-- ============================================================
-- 学生管理系统 - 数据库初始化脚本
-- 数据库：student_management
-- MySQL 8.0+
-- 密码：所有用户密码均为 123456（BCrypt 加密）
-- ============================================================

DROP DATABASE IF EXISTS student_management;
CREATE DATABASE student_management
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE student_management;

-- ============================================================
-- 1. 系统用户表
-- ============================================================
CREATE TABLE sys_user (
    id          BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '主键',
    username    VARCHAR(50)  NOT NULL                 COMMENT '用户名',
    password    VARCHAR(200) NOT NULL                 COMMENT '密码（BCrypt）',
    real_name   VARCHAR(50)  NOT NULL                 COMMENT '真实姓名',
    phone       VARCHAR(20)  DEFAULT NULL             COMMENT '手机号',
    email       VARCHAR(100) DEFAULT NULL             COMMENT '邮箱',
    status      TINYINT      NOT NULL DEFAULT 1       COMMENT '0=禁用 1=启用',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- ============================================================
-- 2. 角色表
-- ============================================================
CREATE TABLE sys_role (
    id          BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '主键',
    role_name   VARCHAR(50)  NOT NULL                 COMMENT '角色名称',
    role_code   VARCHAR(50)  NOT NULL                 COMMENT '角色编码',
    description VARCHAR(255) DEFAULT NULL             COMMENT '描述',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_role_code (role_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- ============================================================
-- 3. 用户角色关联表
-- ============================================================
CREATE TABLE sys_user_role (
    id      BIGINT NOT NULL AUTO_INCREMENT  COMMENT '主键',
    user_id BIGINT NOT NULL                 COMMENT '用户ID',
    role_id BIGINT NOT NULL                 COMMENT '角色ID',
    PRIMARY KEY (id),
    KEY idx_user (user_id),
    KEY idx_role (role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES sys_role(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- ============================================================
-- 4. 班级表
-- ============================================================
CREATE TABLE class (
    id              BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '主键',
    class_name      VARCHAR(100) NOT NULL                 COMMENT '班级名称',
    grade           VARCHAR(20)  NOT NULL                 COMMENT '年级',
    head_teacher_id BIGINT       DEFAULT NULL             COMMENT '班主任ID',
    room            VARCHAR(50)  DEFAULT NULL             COMMENT '教室号',
    description     VARCHAR(500) DEFAULT NULL             COMMENT '班级描述',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_class_name (class_name),
    CONSTRAINT fk_class_teacher FOREIGN KEY (head_teacher_id) REFERENCES sys_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级表';

-- ============================================================
-- 5. 学生表
-- ============================================================
CREATE TABLE student (
    id              BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '主键',
    student_no      VARCHAR(30)  NOT NULL                 COMMENT '学号',
    name            VARCHAR(50)  NOT NULL                 COMMENT '姓名',
    gender          TINYINT      DEFAULT 0                COMMENT '0=未知 1=男 2=女',
    birthday        DATE         DEFAULT NULL             COMMENT '出生日期',
    phone           VARCHAR(20)  DEFAULT NULL             COMMENT '联系电话',
    email           VARCHAR(100) DEFAULT NULL             COMMENT '邮箱',
    address         VARCHAR(255) DEFAULT NULL             COMMENT '家庭住址',
    class_id        BIGINT       DEFAULT NULL             COMMENT '所属班级ID',
    enrollment_date DATE         DEFAULT NULL             COMMENT '入学日期',
    status          TINYINT      DEFAULT 1                COMMENT '0=休学 1=在读 2=毕业',
    user_id         BIGINT       DEFAULT NULL             COMMENT '关联登录账号ID',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_student_no (student_no),
    KEY idx_name (name),
    KEY idx_class (class_id),
    CONSTRAINT fk_student_class FOREIGN KEY (class_id) REFERENCES class(id) ON DELETE SET NULL,
    CONSTRAINT fk_student_user  FOREIGN KEY (user_id)  REFERENCES sys_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

-- ============================================================
-- 6. 课程表
-- ============================================================
CREATE TABLE course (
    id          BIGINT        NOT NULL AUTO_INCREMENT  COMMENT '主键',
    course_name VARCHAR(100)  NOT NULL                 COMMENT '课程名称',
    course_code VARCHAR(30)   NOT NULL                 COMMENT '课程编号',
    credit      DECIMAL(3,1)  DEFAULT 0.0              COMMENT '学分',
    hours       INT           DEFAULT 0                COMMENT '课时',
    description VARCHAR(500)  DEFAULT NULL             COMMENT '课程描述',
    create_time DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_course_code (course_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- ============================================================
-- 7. 排课表（班级-课程关联）
-- ============================================================
CREATE TABLE class_course (
    id          BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '主键',
    class_id    BIGINT       NOT NULL                 COMMENT '班级ID',
    course_id   BIGINT       NOT NULL                 COMMENT '课程ID',
    teacher_id  BIGINT       NOT NULL                 COMMENT '授课教师ID',
    semester    VARCHAR(30)  NOT NULL                 COMMENT '学期 如2024-2025-2',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_cc_semester (class_id, course_id, semester),
    KEY idx_cc_teacher (teacher_id),
    CONSTRAINT fk_cc_class   FOREIGN KEY (class_id)   REFERENCES class(id)   ON DELETE CASCADE,
    CONSTRAINT fk_cc_course  FOREIGN KEY (course_id)  REFERENCES course(id)  ON DELETE CASCADE,
    CONSTRAINT fk_cc_teacher FOREIGN KEY (teacher_id) REFERENCES sys_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='排课表';

-- ============================================================
-- 8. 成绩表
-- ============================================================
CREATE TABLE score (
    id              BIGINT        NOT NULL AUTO_INCREMENT  COMMENT '主键',
    student_id      BIGINT        NOT NULL                 COMMENT '学生ID',
    class_course_id BIGINT        NOT NULL                 COMMENT '排课ID',
    score           DECIMAL(5,2)  DEFAULT NULL             COMMENT '分数 0.00~100.00',
    exam_type       VARCHAR(20)   DEFAULT '期末'           COMMENT '期中/期末/补考',
    remark          VARCHAR(255)  DEFAULT NULL             COMMENT '备注',
    create_time     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_score_exam (student_id, class_course_id, exam_type),
    KEY idx_score_cc (class_course_id),
    CONSTRAINT fk_score_student FOREIGN KEY (student_id)      REFERENCES student(id)      ON DELETE CASCADE,
    CONSTRAINT fk_score_cc      FOREIGN KEY (class_course_id) REFERENCES class_course(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成绩表';


-- ============================================================
-- 初始数据
-- ============================================================

-- 角色
INSERT INTO sys_role (id, role_name, role_code, description) VALUES
(1, '管理员', 'ROLE_ADMIN',   '系统管理员，拥有全部功能权限'),
(2, '教师',   'ROLE_TEACHER', '查看所教班级学生，录入与修改成绩'),
(3, '学生',   'ROLE_STUDENT', '查看个人信息和成绩');

-- 用户（密码均为 123456）
INSERT INTO sys_user (id, username, password, real_name, phone, status) VALUES
(1, 'admin',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', '13800000001', 1),
(2, 'zhang',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张老师',     '13800000002', 1),
(3, 'li',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李老师',     '13800000003', 1),
(4,  'wang',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '王老师',     '13800000004', 1),
(5,  'liu',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '刘老师',     '13800000005', 1),
(6,  'chen',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '陈老师',     '13800000006', 1),
(7,  'yang',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '杨老师',     '13800000007', 1),
(8,  'zhao_j', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '赵老师',     '13800000008', 1),
(9,  'huang',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黄老师',     '13800000009', 1),
(10, 'lin',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '林老师',     '13800000010', 1),
(11, 'zhou_j', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '周老师',     '13800000011', 1),
(12, 'wu',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '吴老师',     '13800000012', 1);

-- 用户-角色关联
INSERT INTO sys_user_role (user_id, role_id) VALUES
(1, 1),  -- admin → 管理员
(2, 2),  -- zhang → 教师
(3, 2),  -- li    → 教师
(4, 2),  -- wang   → 教师
(5, 2),  -- liu    → 教师
(6, 2),  -- chen   → 教师
(7, 2),  -- yang   → 教师
(8, 2),  -- zhao_j → 教师
(9, 2),  -- huang  → 教师
(10, 2), -- lin    → 教师
(11, 2), -- zhou_j → 教师
(12, 2); -- wu     → 教师

-- 班级
INSERT INTO class (id, class_name, grade, head_teacher_id, room, description) VALUES
(1,  '软件工程241',   '2024级', 2,  'A101', '计算机学院软件工程专业'),
(2,  '软件工程242',   '2024级', 3,  'A102', '计算机学院软件工程专业'),
(3,  '计算机科学241', '2024级', 4,  'B201', '计算机学院计算机科学专业'),
(4,  '计算机科学242', '2024级', 5,  'B202', '计算机学院计算机科学专业'),
(5,  '人工智能241',   '2024级', 6,  'C101', '人工智能学院人工智能专业'),
(6,  '人工智能242',   '2024级', 7,  'C102', '人工智能学院人工智能专业'),
(7,  '软件工程233',   '2023级', 8,  'A103', '计算机学院软件工程专业'),
(8,  '计算机科学233', '2023级', 9,  'B203', '计算机学院计算机科学专业'),
(9,  '网络工程241',   '2024级', 10, 'D101', '计算机学院网络工程专业'),
(10, '大数据241',     '2024级', 11, 'D102', '大数据学院数据科学与大数据技术专业'),
(11, '物联网231',     '2023级', 12, 'A104', '计算机学院物联网工程专业');

-- ============================================================
-- 学生数据（52条，按班级分组）
-- ============================================================

-- 软件工程1班（2024级，class_id=1）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(1, '2024001', '张三',   1, '2005-03-15', '13900001001', 1, '2024-09-01', 1),
(2, '2024002', '李四',   2, '2005-07-22', '13900001002', 1, '2024-09-01', 1),
(3, '2024003', '王五',   1, '2005-01-10', '13900001003', 1, '2024-09-01', 1),
(7, '20240104', '刘洋',   1, '2005-04-18', '13900001007', 1, '2024-09-01', 1),
(8, '20240105', '陈思雨', 2, '2005-12-03', '13900001008', 1, '2024-09-01', 1);

-- 软件工程2班（2024级，class_id=2）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(4,  '2024004', '赵六',   2, '2005-11-08', '13900001004', 2, '2024-09-01', 1),
(5,  '2024005', '孙七',   1, '2004-06-20', '13900001005', 2, '2024-09-01', 1),
(9,  '20240203', '吴晓明', 1, '2005-02-28', '13900001009', 2, '2024-09-01', 1),
(10, '20240204', '郑丽华', 2, '2005-08-15', '13900001010', 2, '2024-09-01', 1),
(11, '20240205', '冯志强', 1, '2004-11-22', '13900001011', 2, '2024-09-01', 1);

-- 计算机科学1班（2024级，class_id=3）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(6,  '2024006', '周八',   2, '2005-09-03', '13900001006', 3, '2024-09-01', 1),
(12, '20240302', '褚思远', 1, '2005-05-30', '13900001012', 3, '2024-09-01', 1),
(13, '20240303', '蒋晓雯', 2, '2005-09-14', '13900001013', 3, '2024-09-01', 1),
(14, '20240304', '沈浩宇', 1, '2005-01-07', '13900001014', 3, '2024-09-01', 1),
(15, '20240305', '韩雨桐', 2, '2004-06-25', '13900001015', 3, '2024-09-01', 1);

-- 计算机科学2班（2024级，class_id=4）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(16, '20240401', '唐子涵', 1, '2005-10-12', '13900001016', 4, '2024-09-01', 1),
(17, '20240402', '秦月',   2, '2005-03-08', '13900001017', 4, '2024-09-01', 1),
(18, '20240403', '许鹏飞', 1, '2004-12-19', '13900001018', 4, '2024-09-01', 1),
(19, '20240404', '尤佳怡', 2, '2006-01-15', '13900001019', 4, '2024-09-01', 1),
(20, '20240405', '苏瑞',   1, '2005-07-04', '13900001020', 4, '2024-09-01', 1);

-- 人工智能1班（2024级，class_id=5）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(21, '20240501', '卢志伟', 1, '2005-08-23', '13900001021', 5, '2024-09-01', 1),
(22, '20240502', '蒋欣怡', 2, '2005-06-17', '13900001022', 5, '2024-09-01', 1),
(23, '20240503', '蔡明轩', 1, '2004-09-30', '13900001023', 5, '2024-09-01', 1),
(24, '20240504', '丁雨萱', 2, '2005-02-14', '13900001024', 5, '2024-09-01', 1),
(25, '20240505', '魏子豪', 1, '2005-11-05', '13900001025', 5, '2024-09-01', 1);

-- 人工智能2班（2024级，class_id=6）- 4人（含1人休学）
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(26, '20240601', '薛雅文', 2, '2005-04-22', '13900001026', 6, '2024-09-01', 1),
(27, '20240602', '阎俊杰', 1, '2004-10-17', '13900001027', 6, '2024-09-01', 1),
(28, '20240603', '余思琪', 2, '2005-07-09', '13900001028', 6, '2024-09-01', 1),
(29, '20240604', '潘博文', 1, '2006-03-28', '13900001029', 6, '2024-09-01', 0);

-- 软件工程3班（2023级，class_id=7）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(30, '20230701', '戴浩然', 1, '2004-09-12', '13900001030', 7, '2023-09-01', 1),
(31, '20230702', '夏雨菲', 2, '2004-12-25', '13900001031', 7, '2023-09-01', 1),
(32, '20230703', '钟明辉', 1, '2005-01-18', '13900001032', 7, '2023-09-01', 1),
(33, '20230704', '汪晓琳', 2, '2004-05-06', '13900001033', 7, '2023-09-01', 1),
(34, '20230705', '田宇轩', 1, '2004-08-30', '13900001034', 7, '2023-09-01', 1);

-- 计算机科学3班（2023级，class_id=8）- 4人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(35, '20230801', '任嘉豪', 1, '2004-11-14', '13900001035', 8, '2023-09-01', 1),
(36, '20230802', '范雪莹', 2, '2005-02-07', '13900001036', 8, '2023-09-01', 1),
(37, '20230803', '方文博', 1, '2004-04-19', '13900001037', 8, '2023-09-01', 1),
(38, '20230804', '姚梦洁', 2, '2004-07-28', '13900001038', 8, '2023-09-01', 1);

-- 网络工程1班（2024级，class_id=9）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(39, '20240901', '谭子轩', 1, '2005-05-12', '13900001039', 9, '2024-09-01', 1),
(40, '20240902', '廖雨欣', 2, '2005-09-08', '13900001040', 9, '2024-09-01', 1),
(41, '20240903', '邹明哲', 1, '2004-12-03', '13900001041', 9, '2024-09-01', 1),
(42, '20240904', '熊思颖', 2, '2006-02-19', '13900001042', 9, '2024-09-01', 1),
(43, '20240905', '金志远', 1, '2005-03-26', '13900001043', 9, '2024-09-01', 1);

-- 大数据1班（2024级，class_id=10）- 4人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(44, '20241001', '陆浩宁', 1, '2005-10-30', '13900001044', 10, '2024-09-01', 1),
(45, '20241002', '孔晓萌', 2, '2005-06-14', '13900001045', 10, '2024-09-01', 1),
(46, '20241003', '白瑞峰', 1, '2004-08-05', '13900001046', 10, '2024-09-01', 1),
(47, '20241004', '崔文静', 2, '2005-01-22', '13900001047', 10, '2024-09-01', 1);

-- 物联网1班（2023级，class_id=11）- 5人
INSERT INTO student (id, student_no, name, gender, birthday, phone, class_id, enrollment_date, status) VALUES
(48, '20231101', '邱天宇', 1, '2004-10-09', '13900001048', 11, '2023-09-01', 1),
(49, '20231102', '秦诗涵', 2, '2004-03-16', '13900001049', 11, '2023-09-01', 1),
(50, '20231103', '江明远', 1, '2005-04-27', '13900001050', 11, '2023-09-01', 1),
(51, '20231104', '史雨萌', 2, '2004-07-13', '13900001051', 11, '2023-09-01', 1),
(52, '20231105', '顾浩然', 1, '2004-12-08', '13900001052', 11, '2023-09-01', 1);

-- 课程
INSERT INTO course (id, course_name, course_code, credit, hours) VALUES
(1, 'Java程序设计',   'CS101',   4.0, 64),
(2, '数据库原理',     'CS102',   3.0, 48),
(3, '数据结构与算法',  'CS103',   4.0, 64),
(4, 'Web前端开发',    'CS104',   3.0, 48),
(5, '软件工程',       'CS105',   3.0, 48),
(6, '高等数学',       'MATH101', 5.0, 80);

-- 排课（班级 + 课程 + 授课教师 + 学期）
INSERT INTO class_course (id, class_id, course_id, teacher_id, semester) VALUES
(1, 1, 1, 2, '2024-2025-2'),   -- 软件1班 Java 张老师
(2, 1, 2, 3, '2024-2025-2'),   -- 软件1班 数据库 李老师
(3, 1, 4, 2, '2024-2025-2'),   -- 软件1班 Web前端 张老师
(4, 2, 1, 2, '2024-2025-2'),   -- 软件2班 Java 张老师
(5, 2, 2, 3, '2024-2025-2'),   -- 软件2班 数据库 李老师
(6, 3, 6, 4, '2024-2025-2');   -- 计科1班 高等数学 王老师

-- 成绩
INSERT INTO score (student_id, class_course_id, score, exam_type) VALUES
-- 张三
(1, 1, 89.5, '期中'), (1, 1, 92.0, '期末'),
(1, 2, 85.5, '期末'),
(1, 3, 90.0, '期末'),
-- 李四
(2, 1, 76.0, '期中'), (2, 1, 81.5, '期末'),
(2, 2, 93.0, '期末'),
(2, 3, 87.0, '期末'),
-- 王五
(3, 1, 65.0, '期中'), (3, 1, 72.0, '期末'),
(3, 2, 80.0, '期末'),
-- 赵六
(4, 4, 91.0, '期中'), (4, 4, 95.5, '期末'),
(4, 5, 83.0, '期末'),
-- 孙七
(5, 4, 70.0, '期中'), (5, 4, 77.0, '期末'),
(5, 5, 68.0, '期末'),
-- 周八
(6, 6, 55.0, '期中'), (6, 6, 60.0, '期末');
