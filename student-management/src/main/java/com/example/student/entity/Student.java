package com.example.student.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("student")
public class Student {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String studentNo;
    private String name;
    private Integer gender;
    private LocalDate birthday;
    private String phone;
    private String email;
    private String address;
    private Long classId;
    private LocalDate enrollmentDate;
    private Integer status;
    private Long userId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /** 班级名称（非数据库字段） */
    @TableField(exist = false)
    private String className;

    /** 班主任姓名（非数据库字段） */
    @TableField(exist = false)
    private String headTeacherName;
}
