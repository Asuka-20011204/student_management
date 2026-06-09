package com.example.student.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.BusinessException;
import com.example.student.dto.StudentQuery;
import com.example.student.entity.Student;
import com.example.student.mapper.StudentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class StudentService {

    private final StudentMapper studentMapper;

    public IPage<Student> pageQuery(StudentQuery query) {
        Page<Student> page = new Page<>(query.getPage(), query.getPageSize());
        return studentMapper.selectPageWithClass(page, query.getName(), query.getStudentNo(), query.getClassId());
    }

    public Student getById(Long id) {
        Student student = studentMapper.selectById(id);
        if (student == null) {
            throw new BusinessException(404, "学生不存在");
        }
        return student;
    }

    @Transactional
    public void create(Student student) {
        studentMapper.insert(student);
    }

    @Transactional
    public void update(Student student) {
        Student db = studentMapper.selectById(student.getId());
        if (db == null) {
            throw new BusinessException(404, "学生不存在");
        }
        studentMapper.updateById(student);
    }

    @Transactional
    public void delete(Long id) {
        studentMapper.deleteById(id);
    }

    @Transactional
    public void batchDelete(List<Long> ids) {
        studentMapper.deleteBatchIds(ids);
    }
}
