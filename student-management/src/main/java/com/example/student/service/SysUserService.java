package com.example.student.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.BusinessException;
import com.example.student.entity.SysUser;
import com.example.student.entity.SysUserRole;
import com.example.student.mapper.SysUserMapper;
import com.example.student.mapper.SysUserRoleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SysUserService {

    private final SysUserMapper sysUserMapper;
    private final SysUserRoleMapper sysUserRoleMapper;
    private final PasswordEncoder passwordEncoder;

    public Page<SysUser> page(int pageNum, int pageSize, String keyword, Long roleId) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(SysUser::getUsername, keyword)
                   .or().like(SysUser::getRealName, keyword);
        }
        // 按角色筛选
        if (roleId != null) {
            List<Long> userIds = sysUserRoleMapper.selectList(
                new LambdaQueryWrapper<SysUserRole>().eq(SysUserRole::getRoleId, roleId)
            ).stream().map(SysUserRole::getUserId).toList();
            if (userIds.isEmpty()) {
                return new Page<>(pageNum, pageSize);  // 空结果
            }
            wrapper.in(SysUser::getId, userIds);
        }
        wrapper.orderByDesc(SysUser::getId);
        return sysUserMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    public SysUser getById(Long id) {
        SysUser user = sysUserMapper.selectById(id);
        if (user != null) {
            user.setPassword(null); // 不返回密码
        }
        return user;
    }

    @Transactional
    public void create(SysUser user, List<Long> roleIds) {
        // 检查用户名唯一
        Long count = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, user.getUsername()));
        if (count > 0) {
            throw new BusinessException("用户名已存在");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        sysUserMapper.insert(user);
        // 分配角色
        if (roleIds != null) {
            for (Long roleId : roleIds) {
                SysUserRole ur = new SysUserRole();
                ur.setUserId(user.getId());
                ur.setRoleId(roleId);
                sysUserRoleMapper.insert(ur);
            }
        }
    }

    @Transactional
    public void update(SysUser user, List<Long> roleIds) {
        SysUser dbUser = sysUserMapper.selectById(user.getId());
        if (dbUser == null) {
            throw new BusinessException("用户不存在");
        }
        // 如果修改了密码
        if (user.getPassword() != null && !user.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        } else {
            user.setPassword(null); // 不修改密码
        }
        sysUserMapper.updateById(user);
        // 更新角色
        if (roleIds != null) {
            sysUserRoleMapper.delete(
                    new LambdaQueryWrapper<SysUserRole>().eq(SysUserRole::getUserId, user.getId()));
            for (Long roleId : roleIds) {
                SysUserRole ur = new SysUserRole();
                ur.setUserId(user.getId());
                ur.setRoleId(roleId);
                sysUserRoleMapper.insert(ur);
            }
        }
    }

    @Transactional
    public void delete(Long id) {
        sysUserRoleMapper.delete(
                new LambdaQueryWrapper<SysUserRole>().eq(SysUserRole::getUserId, id));
        sysUserMapper.deleteById(id);
    }

    /** 获取用户角色ID列表 */
    public List<Long> getUserRoleIds(Long userId) {
        return sysUserRoleMapper.selectList(
                new LambdaQueryWrapper<SysUserRole>().eq(SysUserRole::getUserId, userId))
                .stream().map(SysUserRole::getRoleId).toList();
    }

    /** 修改密码 */
    public void changePassword(Long userId, String oldPwd, String newPwd) {
        SysUser user = sysUserMapper.selectById(userId);
        if (!passwordEncoder.matches(oldPwd, user.getPassword())) {
            throw new BusinessException("原密码错误");
        }
        user.setPassword(passwordEncoder.encode(newPwd));
        sysUserMapper.updateById(user);
    }
}
