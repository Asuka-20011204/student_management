package com.example.student.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.student.common.BusinessException;
import com.example.student.config.JwtUtil;
import com.example.student.dto.LoginRequest;
import com.example.student.dto.LoginResponse;
import com.example.student.entity.SysUser;
import com.example.student.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final SysUserMapper sysUserMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public LoginResponse login(LoginRequest request) {
        // 1. 查用户
        SysUser user = sysUserMapper.selectOne(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, request.getUsername())
        );
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BusinessException("账号已被禁用");
        }

        // 2. 验密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }

        // 3. 查角色
        List<String> roles = sysUserMapper.selectRoleCodesByUserId(user.getId());

        // 4. 生成 JWT
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", roles.isEmpty() ? "ROLE_STUDENT" : roles.get(0));
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), claims);

        // 5. 返回
        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .realName(user.getRealName())
                .roles(roles)
                .build();
    }
}
