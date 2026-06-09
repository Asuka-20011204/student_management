package com.example.student.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 班级实体（表名 class，Java 中用 Clazz 避免关键字冲突）
 */
@Data
@TableName("class")
public class Clazz {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String className;
    private String grade;
    private Long headTeacherId;
    private String room;
    private String description;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /** 班级人数（非数据库字段） */
    @TableField(exist = false)
    private Integer studentCount;
}
