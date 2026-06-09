package com.example.student.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.entity.Student;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface StudentMapper extends BaseMapper<Student> {

    /** 分页查询学生，关联班级名称 */
    @Select("""
        <script>
        SELECT s.*, c.class_name
        FROM student s
        LEFT JOIN class c ON s.class_id = c.id
        <where>
            <if test='name != null and name != \"\"'>
                AND s.name LIKE CONCAT('%', #{name}, '%')
            </if>
            <if test='studentNo != null and studentNo != \"\"'>
                AND s.student_no LIKE CONCAT('%', #{studentNo}, '%')
            </if>
            <if test='classId != null'>
                AND s.class_id = #{classId}
            </if>
        </where>
        ORDER BY s.id DESC
        </script>
    """)
    IPage<Student> selectPageWithClass(Page<Student> page,
                                       @Param("name") String name,
                                       @Param("studentNo") String studentNo,
                                       @Param("classId") Long classId);
}
