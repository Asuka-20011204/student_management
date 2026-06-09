package com.example.student.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.Result;
import com.example.student.entity.SysRole;
import com.example.student.entity.SysUser;
import com.example.student.mapper.SysRoleMapper;
import com.example.student.service.SysUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final SysUserService sysUserService;
    private final SysRoleMapper sysRoleMapper;

    /** 分页 */
    @GetMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Page<SysUser>> list(@RequestParam(defaultValue = "1") int page,
                                       @RequestParam(defaultValue = "10") int pageSize,
                                       @RequestParam(required = false) String keyword,
                                       @RequestParam(required = false) Long roleId) {
        Page<SysUser> result = sysUserService.page(page, pageSize, keyword, roleId);
        // 不返回密码
        for (SysUser user : result.getRecords()) {
            user.setPassword(null);
        }
        return Result.ok(result);
    }

    /** 创建 */
    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> create(@RequestBody Map<String, Object> params) {
        SysUser user = new SysUser();
        user.setUsername((String) params.get("username"));
        user.setPassword((String) params.get("password"));
        user.setRealName((String) params.get("realName"));
        user.setPhone((String) params.get("phone"));
        user.setEmail((String) params.get("email"));
        user.setStatus((Integer) params.getOrDefault("status", 1));

        @SuppressWarnings("unchecked")
        List<Integer> roleIdInts = (List<Integer>) params.get("roleIds");
        List<Long> roleIds = roleIdInts != null
                ? roleIdInts.stream().map(Long::valueOf).toList() : null;

        sysUserService.create(user, roleIds);
        return Result.ok();
    }

    /** 编辑 */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> update(@PathVariable Long id, @RequestBody Map<String, Object> params) {
        SysUser user = new SysUser();
        user.setId(id);
        user.setUsername((String) params.get("username"));
        user.setRealName((String) params.get("realName"));
        user.setPhone((String) params.get("phone"));
        user.setEmail((String) params.get("email"));
        user.setStatus((Integer) params.getOrDefault("status", 1));
        if (params.containsKey("password")) {
            user.setPassword((String) params.get("password"));
        }

        @SuppressWarnings("unchecked")
        List<Integer> roleIdInts = (List<Integer>) params.get("roleIds");
        List<Long> roleIds = roleIdInts != null
                ? roleIdInts.stream().map(Long::valueOf).toList() : null;

        sysUserService.update(user, roleIds);
        return Result.ok();
    }

    /** 删除 */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<Void> delete(@PathVariable Long id) {
        sysUserService.delete(id);
        return Result.ok();
    }

    /** 获取某用户的角色ID列表 */
    @GetMapping("/{id}/roles")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<List<Long>> userRoles(@PathVariable Long id) {
        return Result.ok(sysUserService.getUserRoleIds(id));
    }

    /** 获取所有角色 */
    @GetMapping("/roles")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<List<SysRole>> allRoles() {
        return Result.ok(sysRoleMapper.selectList(null));
    }
}
