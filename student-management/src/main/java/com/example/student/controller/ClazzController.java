package com.example.student.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.Result;
import com.example.student.entity.Clazz;
import com.example.student.service.ClazzService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/classes")
@RequiredArgsConstructor
public class ClazzController {

    private final ClazzService clazzService;

    /** 分页查询 */
    @GetMapping
    public Result<Page<Clazz>> list(@RequestParam(defaultValue = "1") int page,
                                     @RequestParam(defaultValue = "10") int pageSize,
                                     @RequestParam(required = false) String keyword) {
        return Result.ok(clazzService.page(page, pageSize, keyword));
    }

    /** 详情 */
    @GetMapping("/{id}")
    public Result<Clazz> detail(@PathVariable Long id) {
        return Result.ok(clazzService.getById(id));
    }

    /** 新增 */
    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> create(@RequestBody Clazz clazz) {
        clazzService.create(clazz);
        return Result.ok();
    }

    /** 编辑 */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> update(@PathVariable Long id, @RequestBody Clazz clazz) {
        clazz.setId(id);
        clazzService.update(clazz);
        return Result.ok();
    }

    /** 删除 */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> delete(@PathVariable Long id) {
        clazzService.delete(id);
        return Result.ok();
    }
}
