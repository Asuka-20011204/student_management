# Spring Boot 分层架构与数据流转说明

## 一、各文件的作用

### 1. Controller（控制器层）

Controller 是前后端交互的入口，负责接收前端发来的 HTTP 请求，调用 Service 层处理业务逻辑，然后将结果返回给前端。

Controller 本身不写业务代码，它的职责是：解析请求参数（路径参数、查询参数、请求体），校验参数合法性，调用对应的 Service 方法，最后将 Service 返回的结果封装成统一响应格式返回。Controller 类上通常用 @RestController 注解标识，方法上通过 @GetMapping、@PostMapping、@PutMapping、@DeleteMapping 等注解映射不同的请求路径和请求方式。

### 2. Service（业务逻辑层）

Service 是业务逻辑的核心，负责处理具体的业务规则。它接收 Controller 传来的参数，进行业务判断、数据校验、数据转换，然后调用 Mapper 层操作数据库，最后将处理结果返回给 Controller。

Service 层可以调用一个或多个 Mapper 来完成一次业务操作。比如录入成绩时，Service 需要先调用 Mapper 查询学生是否存在、查询排课记录是否有效，再调用 Mapper 插入成绩数据。这些有先后顺序的数据库操作和判断逻辑都在 Service 中完成。Service 类上通常用 @Service 注解标识，通过构造器注入的方式引入需要的 Mapper。

### 3. Mapper（数据访问层接口）

Mapper 是 Java 接口，定义了操作数据库的方法。它本身不用写实现类，MyBatis 或 MyBatis-Plus 框架会在运行时自动生成代理实现类。

如果使用 MyBatis-Plus，只需让 Mapper 接口继承 BaseMapper，就能自动获得常用的增删改查方法，比如 selectById、insert、updateById、deleteById 等。如果查询逻辑复杂，可以在 Mapper 接口中自定义方法，然后在对应的 Mapper.xml 中写 SQL。

### 4. Mapper.xml（SQL 映射文件）

Mapper.xml 是 MyBatis 的 SQL 映射文件，用于编写自定义的 SQL 语句。它和 Mapper 接口一一对应，文件名通常和 Mapper 接口名一致。

在 Mapper.xml 中，可以写 SELECT、INSERT、UPDATE、DELETE 等 SQL 语句。每个 SQL 语句需要一个唯一 id，这个 id 和 Mapper 接口中的方法名对应。查询结果可以通过 resultType 或 resultMap 映射成 Java 实体对象。如果涉及多表联查，需要自定义 resultMap 来映射字段关系。MyBatis-Plus 的内置方法不需要在 Mapper.xml 中写 SQL，只有复杂查询或需要优化的 SQL 才写在 Mapper.xml 里。

---

## 二、数据流转过程

当浏览器或前端发起一个请求，数据在 Spring Boot 各层之间的流转顺序如下：

第一步，前端发送请求。浏览器向某个 URL 发送 HTTP 请求，比如 GET 请求 /api/students?page=1&pageSize=10，请求到达 Spring Boot 内嵌的 Tomcat 服务器。

第二步，请求进入 Controller。Spring MVC 的前端控制器 DispatcherServlet 根据请求的 URL 和请求方式，匹配到对应的 Controller 方法。Controller 方法接收请求参数，这些参数可能来自 URL 路径、问号后的查询字符串、或者请求体中的 JSON 数据。Controller 做基本的参数校验后，将参数传给 Service 方法。

第三步，Service 处理业务逻辑。Service 收到参数后，执行具体的业务规则。比如查询学生列表时，Service 可能先检查当前用户权限，再构造查询条件，然后调用 Mapper 的分页查询方法。如果业务涉及多个数据库操作，Service 会按顺序协调这些操作，必要时加上事务保证数据一致性。

第四步，Mapper 执行数据库操作。Mapper 接口的方法被 Service 调用后，MyBatis 框架找到对应的 SQL。如果是 MyBatis-Plus 内置方法，框架自动生成 SQL 并执行。如果是自定义方法，框架去 Mapper.xml 中找到对应 id 的 SQL 语句，将参数填入 SQL 的占位符，然后通过 JDBC 发送给 MySQL 数据库执行。

第五步，数据库返回结果。MySQL 执行 SQL 后，将查询结果返回给 JDBC。MyBatis 根据映射规则，将数据库返回的行数据转换成 Java 实体对象或对象列表。如果是分页查询，MyBatis-Plus 还会自动封装分页信息（总记录数、当前页、每页条数）。

第六步，结果逐层返回。Mapper 将结果返回给 Service，Service 可能会对结果做进一步处理，比如脱敏手机号、计算附加字段等，然后将处理后的结果返回给 Controller。Controller 将结果封装成统一响应格式，比如包含 code、message、data 三个字段的 JSON 对象，最后返回给前端。

第七步，前端收到响应。前端拿到 JSON 数据后，解析并渲染到页面上。

总结来说，数据流向是：前端请求 → Controller（接收参数）→ Service（处理业务）→ Mapper（操作数据库）→ 数据库 → Mapper（返回实体）→ Service（处理结果）→ Controller（封装响应）→ 前端。各层职责分明，Controller 只管接请求和返回结果，Service 只管业务逻辑，Mapper 只管数据库操作，互不越界。
