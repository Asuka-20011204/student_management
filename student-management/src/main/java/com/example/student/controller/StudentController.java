package com.example.student.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.student.common.Result;
import com.example.student.dto.StudentQuery;
import com.example.student.entity.Student;
import com.example.student.service.StudentService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentController {

    private final StudentService studentService;

    /** 分页查询 */
    @GetMapping
    public Result<IPage<Student>> list(StudentQuery query) {
        return Result.ok(studentService.pageQuery(query));
    }

    /** 详情 */
    @GetMapping("/{id}")
    public Result<Student> detail(@PathVariable Long id) {
        return Result.ok(studentService.getById(id));
    }

    /** 新增 */
    @PostMapping
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_TEACHER')")
    public Result<Void> create(@RequestBody Student student) {
        studentService.create(student);
        return Result.ok();
    }

    /** 编辑 */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_TEACHER')")
    public Result<Void> update(@PathVariable Long id, @RequestBody Student student) {
        student.setId(id);
        studentService.update(student);
        return Result.ok();
    }

    /** 删除 */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> delete(@PathVariable Long id) {
        studentService.delete(id);
        return Result.ok();
    }

    /** 批量删除 */
    @DeleteMapping("/batch")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> batchDelete(@RequestBody List<Long> ids) {
        studentService.batchDelete(ids);
        return Result.ok();
    }
}
