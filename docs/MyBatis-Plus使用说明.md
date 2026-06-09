# MyBatis-Plus 使用说明

## 一、MyBatis-Plus 是什么

MyBatis-Plus 是 MyBatis 的增强工具，核心作用是简化数据库操作。原生 MyBatis 需要手写每一条 SQL，而 MyBatis-Plus 内置了常用 CRUD 方法，单表操作不用写 SQL。它还提供分页插件、逻辑删除、主键自动生成等功能。它不是替代 MyBatis，而是在其基础上增强，复杂查询时仍然可以手写 SQL。

## 二、Mapper 层使用方式

Mapper 接口继承 BaseMapper 并指定实体类泛型，即可直接使用 insert、deleteById、updateById、selectById、selectList 等内置方法，无需写 SQL。

复杂查询时自定义方法，用 @Select 注解写 SQL 或用 Mapper.xml 文件。分页查询时方法第一个参数传 Page 对象，返回类型用 IPage 包裹，在 SQL 中用 if 标签动态拼接条件。

## 三、Service 层使用方式

Service 通过构造器注入 Mapper，调用 Mapper 的方法完成业务操作。新增调用 insert 方法，查询调用 selectById 查不到则抛业务异常，更新先查后改确保记录存在，删除调用 deleteById（配了逻辑删除则自动改为标记删除）。涉及多个数据库操作的方法加 @Transactional 保证事务。
