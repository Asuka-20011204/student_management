package com.example.student.controller;

import com.example.student.common.Result;
import com.example.student.dto.LoginRequest;
import com.example.student.dto.LoginResponse;
import com.example.student.entity.SysUser;
import com.example.student.service.AuthService;
import com.example.student.service.SysUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final SysUserService sysUserService;

    /** 登录 */
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return Result.ok(authService.login(request));
    }

    /** 获取当前登录用户信息 */
    @GetMapping("/user-info")
    public Result<SysUser> userInfo(Authentication authentication) {
        SysUser principal = (SysUser) authentication.getPrincipal();
        return Result.ok(sysUserService.getById(principal.getId()));
    }

    /** 修改密码 */
    @PutMapping("/password")
    public Result<Void> changePassword(@RequestBody Map<String, String> params,
                                        Authentication authentication) {
        SysUser principal = (SysUser) authentication.getPrincipal();
        sysUserService.changePassword(principal.getId(),
                params.get("oldPassword"), params.get("newPassword"));
        return Result.ok("密码修改成功", null);
    }
}
