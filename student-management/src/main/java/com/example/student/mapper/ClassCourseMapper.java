package com.example.student.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.student.entity.ClassCourse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ClassCourseMapper extends BaseMapper<ClassCourse> {

    /** 查询排课列表（带班级名、课程名、教师名） */
    @Select("""
        SELECT cc.*, c.class_name, co.course_name, u.real_name AS teacher_name
        FROM class_course cc
        LEFT JOIN class c     ON cc.class_id   = c.id
        LEFT JOIN course co   ON cc.course_id  = co.id
        LEFT JOIN sys_user u  ON cc.teacher_id = u.id
        ORDER BY cc.id DESC
    """)
    List<ClassCourse> selectListWithDetails();
}
