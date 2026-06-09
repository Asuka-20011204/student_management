# Spring Boot 核心配置文件说明

## 一、pom.xml 的作用

`pom.xml` 是 Maven 项目的核心配置文件，全称 Project Object Model（项目对象模型）。

它的第一个作用是管理项目依赖。在 Spring Boot 项目中，我们通过 pom.xml 声明需要哪些第三方库，比如 spring-boot-starter-web 提供 REST API 和内嵌 Tomcat，mysql-connector-j 用于连接 MySQL 数据库，lombok 用于简化代码。Maven 会自动从中央仓库下载这些依赖。

它的第二个作用是定义项目坐标。通过 groupId（组织名）、artifactId（项目名）、version（版本号）三个字段唯一标识一个项目，方便其他项目引用。

它的第三个作用是配置构建过程。比如指定 Java 版本，配置 spring-boot-maven-plugin 打包插件，使项目能打包成一个可直接运行的 jar 文件。

---

## 二、application.yml 的作用

`application.yml` 是 Spring Boot 的应用配置文件，Spring Boot 启动时会自动读取它来决定框架和第三方库的具体行为。

如果不写任何配置，Spring Boot 会使用默认值，比如端口默认 8080、时区默认 UTC。但实际开发中我们需要根据项目需求自定义配置。

.yml 文件采用层级缩进的写法，相比传统的 .properties 文件的平铺写法，yml 层次更清晰，避免了大量重复前缀。

pom.xml 和 application.yml 的关系可以这样理解：pom.xml 决定了项目装哪些库，application.yml 决定了这些库怎么用。比如 pom.xml 中引入了 MySQL 驱动，application.yml 中就要配置数据库的地址、用户名、密码；pom.xml 中引入了 MyBatis-Plus，application.yml 中就要配置驼峰命名映射、主键生成策略等。

---

## 三、yml 文件的常见配置

### 1. 数据源配置

在 spring.datasource 节点下配置数据库连接信息。需要指定 driver-class-name 为 MySQL 驱动类名 com.mysql.cj.jdbc.Driver。需要配置 url 为数据库连接地址，格式是 jdbc:mysql://服务器地址:端口/数据库名，后面可以带连接参数，比如 useUnicode=true 开启 Unicode 支持防止中文乱码，characterEncoding=utf-8 指定字符集，serverTimezone=Asia/Shanghai 设置时区为中国标准时间避免时间差八小时。还需要配置 username 和 password 为数据库的账号密码。

### 2. 服务器端口配置

在 server.port 节点下配置应用启动的端口号，Spring Boot 默认是 8080，可以根据需要改成其他端口，比如 80 或 9090。

### 3. JSON 日期格式配置

在 spring.jackson 节点下配置 JSON 序列化行为。date-format 可以指定 Date 类型字段在返回给前端的 JSON 中的显示格式，比如 yyyy-MM-dd HH:mm:ss，不配的话默认是 ISO 8601 格式，可读性差。time-zone 需要设为 Asia/Shanghai，否则默认使用 UTC 零时区，会导致日期时间差八小时。

### 4. MyBatis-Plus 配置

在 mybatis-plus.configuration 节点下配置 ORM 框架的行为。map-underscore-to-camel-case 设为 true 后，数据库字段的下划线命名会自动映射为 Java 属性的驼峰命名，比如 create_time 自动对应 createTime。log-impl 可以配置 SQL 日志的输出方式，开发时通常设为 StdOutImpl 输出到控制台方便调试。

在 mybatis-plus.global-config.db-config 节点下配置全局数据库策略。id-type 指定主键生成方式，auto 表示使用数据库自增。logic-delete-field 指定逻辑删除字段名，logic-delete-value 和 logic-not-delete-value 分别指定已删除和未删除的标记值，这样调用删除方法时不会真的删除数据，只是更新标记字段。

### 5. 自定义配置

除了 Spring 内置的配置项，yml 还支持自定义配置。比如可以自定义 jwt 前缀，在其下配置 secret 签名密钥和 expiration 过期时间（单位毫秒）。在 Java 代码中通过 @Value 注解即可读取这些自定义配置的值。
