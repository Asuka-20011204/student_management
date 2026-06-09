package com.example.student.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.BusinessException;
import com.example.student.entity.Clazz;
import com.example.student.entity.Student;
import com.example.student.mapper.ClazzMapper;
import com.example.student.mapper.StudentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ClazzService {

    private final ClazzMapper clazzMapper;
    private final StudentMapper studentMapper;

    public Page<Clazz> page(int pageNum, int pageSize, String keyword) {
        LambdaQueryWrapper<Clazz> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(Clazz::getClassName, keyword)
                   .or().like(Clazz::getGrade, keyword);
        }
        wrapper.orderByDesc(Clazz::getId);
        Page<Clazz> page = clazzMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);

        // 填充班级人数
        for (Clazz clazz : page.getRecords()) {
            Long count = studentMapper.selectCount(
                    new LambdaQueryWrapper<Student>().eq(Student::getClassId, clazz.getId()));
            clazz.setStudentCount(count.intValue());
        }
        return page;
    }

    public Clazz getById(Long id) {
        Clazz clazz = clazzMapper.selectById(id);
        if (clazz != null) {
            Long count = studentMapper.selectCount(
                    new LambdaQueryWrapper<Student>().eq(Student::getClassId, id));
            clazz.setStudentCount(count.intValue());
        }
        return clazz;
    }

    @Transactional
    public void create(Clazz clazz) {
        clazzMapper.insert(clazz);
    }

    @Transactional
    public void update(Clazz clazz) {
        if (clazzMapper.selectById(clazz.getId()) == null) {
            throw new BusinessException(404, "班级不存在");
        }
        clazzMapper.updateById(clazz);
    }

    @Transactional
    public void delete(Long id) {
        // 检查班级下是否有学生
        Long count = studentMapper.selectCount(
                new LambdaQueryWrapper<Student>().eq(Student::getClassId, id));
        if (count > 0) {
            throw new BusinessException("该班级下还有学生，无法删除");
        }
        clazzMapper.deleteById(id);
    }
}
