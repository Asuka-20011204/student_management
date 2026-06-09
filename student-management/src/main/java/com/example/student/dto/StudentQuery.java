package com.example.student.dto;

import lombok.Data;

/**
 * 学生分页查询参数
 */
@Data
public class StudentQuery {

    private Integer page  = 1;
    private Integer pageSize = 10;
    private String name;
    private String studentNo;
    private Long classId;
}
