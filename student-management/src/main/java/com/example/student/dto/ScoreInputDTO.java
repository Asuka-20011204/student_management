package com.example.student.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

/**
 * 成绩录入/修改用的 DTO
 */
@Data
public class ScoreInputDTO {

    @NotNull(message = "学生ID不能为空")
    private Long studentId;

    @NotNull(message = "排课ID不能为空")
    private Long classCourseId;

    private BigDecimal score;
    private String examType = "期末";
    private String remark;
}
