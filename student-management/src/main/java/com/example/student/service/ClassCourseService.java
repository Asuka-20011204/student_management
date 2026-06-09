package com.example.student.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.BusinessException;
import com.example.student.entity.ClassCourse;
import com.example.student.mapper.ClassCourseMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClassCourseService {

    private final ClassCourseMapper classCourseMapper;

    /** 分页查询排课（带关联名称） */
    public Page<ClassCourse> page(int pageNum, int pageSize) {
        Page<ClassCourse> page = new Page<>(pageNum, pageSize);
        // 先查总数
        List<ClassCourse> all = classCourseMapper.selectListWithDetails();
        int total = all.size();
        int from = (pageNum - 1) * pageSize;
        int to = Math.min(from + pageSize, total);
        List<ClassCourse> records = all.subList(Math.min(from, total), to);
        page.setRecords(records);
        page.setTotal(total);
        return page;
    }

    /** 查询某班级的排课列表 */
    public List<ClassCourse> listByClassId(Long classId) {
        LambdaQueryWrapper<ClassCourse> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ClassCourse::getClassId, classId);
        return classCourseMapper.selectList(wrapper);
    }

    @Transactional
    public void create(ClassCourse cc) {
        classCourseMapper.insert(cc);
    }

    @Transactional
    public void update(ClassCourse cc) {
        if (classCourseMapper.selectById(cc.getId()) == null) {
            throw new BusinessException(404, "排课记录不存在");
        }
        classCourseMapper.updateById(cc);
    }

    @Transactional
    public void delete(Long id) {
        classCourseMapper.deleteById(id);
    }
}
