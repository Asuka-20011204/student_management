package com.example.student.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.BusinessException;
import com.example.student.entity.Course;
import com.example.student.mapper.CourseMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final CourseMapper courseMapper;

    public Page<Course> page(int pageNum, int pageSize, String keyword) {
        LambdaQueryWrapper<Course> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(Course::getCourseName, keyword)
                   .or().like(Course::getCourseCode, keyword);
        }
        wrapper.orderByDesc(Course::getId);
        return courseMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Transactional
    public void create(Course course) {
        courseMapper.insert(course);
    }

    @Transactional
    public void update(Course course) {
        if (courseMapper.selectById(course.getId()) == null) {
            throw new BusinessException(404, "课程不存在");
        }
        courseMapper.updateById(course);
    }

    @Transactional
    public void delete(Long id) {
        courseMapper.deleteById(id);
    }
}
