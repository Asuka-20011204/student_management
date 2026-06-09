package com.example.student.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.Result;
import com.example.student.entity.ClassCourse;
import com.example.student.service.ClassCourseService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/class-courses")
@RequiredArgsConstructor
public class ClassCourseController {

    private final ClassCourseService classCourseService;

    /** 分页 */
    @GetMapping
    public Result<Page<ClassCourse>> list(@RequestParam(defaultValue = "1") int page,
                                           @RequestParam(defaultValue = "10") int pageSize) {
        return Result.ok(classCourseService.page(page, pageSize));
    }

    /** 按班级查排课 */
    @GetMapping("/class/{classId}")
    public Result<List<ClassCourse>> listByClass(@PathVariable Long classId) {
        return Result.ok(classCourseService.listByClassId(classId));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> create(@RequestBody ClassCourse cc) {
        classCourseService.create(cc);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> update(@PathVariable Long id, @RequestBody ClassCourse cc) {
        cc.setId(id);
        classCourseService.update(cc);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> delete(@PathVariable Long id) {
        classCourseService.delete(id);
        return Result.ok();
    }
}
