package com.example.student.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("class_course")
public class ClassCourse {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long classId;
    private Long courseId;
    private Long teacherId;
    private String semester;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /* ---- 关联展示字段 ---- */
    @TableField(exist = false)
    private String className;

    @TableField(exist = false)
    private String courseName;

    @TableField(exist = false)
    private String teacherName;
}
