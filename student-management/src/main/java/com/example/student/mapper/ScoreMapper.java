package com.example.student.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.entity.Score;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface ScoreMapper extends BaseMapper<Score> {

    /** 分页查询成绩（多维度筛选） */
    @Select("""
        <script>
        SELECT sc.*, s.name AS student_name, s.student_no,
               co.course_name, c.class_name, cc.semester
        FROM score sc
        LEFT JOIN student s        ON sc.student_id = s.id
        LEFT JOIN class_course cc  ON sc.class_course_id = cc.id
        LEFT JOIN course co        ON cc.course_id = co.id
        LEFT JOIN class c          ON cc.class_id = c.id
        <where>
            <if test='studentName != null and studentName != \"\"'>
                AND s.name LIKE CONCAT('%', #{studentName}, '%')
            </if>
            <if test='classId != null'>
                AND cc.class_id = #{classId}
            </if>
            <if test='courseId != null'>
                AND cc.course_id = #{courseId}
            </if>
            <if test='examType != null and examType != \"\"'>
                AND sc.exam_type = #{examType}
            </if>
            <if test='studentId != null'>
                AND sc.student_id = #{studentId}
            </if>
        </where>
        ORDER BY sc.id DESC
        </script>
    """)
    IPage<Score> selectPageWithDetails(Page<Score> page,
                                       @Param("studentName") String studentName,
                                       @Param("classId") Long classId,
                                       @Param("courseId") Long courseId,
                                       @Param("examType") String examType,
                                       @Param("studentId") Long studentId);

    /** 成绩统计：按班级课程分组 */
    @Select("""
        SELECT c.class_name, co.course_name, cc.semester, sc.exam_type,
               COUNT(*) AS total,
               ROUND(AVG(sc.score), 1) AS avg_score,
               MAX(sc.score) AS max_score,
               MIN(sc.score) AS min_score,
               ROUND(SUM(CASE WHEN sc.score >= 60 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS pass_rate
        FROM score sc
        LEFT JOIN class_course cc ON sc.class_course_id = cc.id
        LEFT JOIN class c         ON cc.class_id = c.id
        LEFT JOIN course co       ON cc.course_id = co.id
        WHERE cc.class_id = #{classId}
          AND cc.course_id = #{courseId}
          AND (sc.exam_type = #{examType} OR #{examType} IS NULL)
        GROUP BY cc.id, c.class_name, co.course_name, cc.semester, sc.exam_type
    """)
    List<Map<String, Object>> selectScoreStats(@Param("classId") Long classId,
                                                @Param("courseId") Long courseId,
                                                @Param("examType") String examType);
}
