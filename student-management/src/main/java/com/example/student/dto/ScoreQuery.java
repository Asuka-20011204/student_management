package com.example.student.dto;

import lombok.Data;

@Data
public class ScoreQuery {

    private Integer page = 1;
    private Integer pageSize = 10;
    private String studentName;
    private Long classId;
    private Long courseId;
    private String examType;
    private Long studentId;   // 学生查自己成绩时用
}
