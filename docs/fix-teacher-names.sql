-- 更新教师姓名为全名
USE student_management;

UPDATE sys_user SET real_name = '张明伟' WHERE username = 'zhang';
UPDATE sys_user SET real_name = '李雪琴' WHERE username = 'li';
UPDATE sys_user SET real_name = '王志强' WHERE username = 'wang';
UPDATE sys_user SET real_name = '刘建国' WHERE username = 'liu';
UPDATE sys_user SET real_name = '陈晓东' WHERE username = 'chen';
UPDATE sys_user SET real_name = '杨海燕' WHERE username = 'yang';
UPDATE sys_user SET real_name = '赵俊杰' WHERE username = 'zhao_j';
UPDATE sys_user SET real_name = '黄丽华' WHERE username = 'huang';
UPDATE sys_user SET real_name = '林文远' WHERE username = 'lin';
UPDATE sys_user SET real_name = '周雅婷' WHERE username = 'zhou_j';
UPDATE sys_user SET real_name = '吴国栋' WHERE username = 'wu';

SELECT id, username, real_name FROM sys_user WHERE id >= 2;
