package com.example.student.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 简易频率限制过滤器
 * - 登录接口：同一 IP 每分钟最多 10 次请求
 * - 其他接口：同一 IP 每秒最多 30 次请求
 */
public class RateLimitFilter implements Filter {

    // IP → 时间窗口起始时间
    private final Map<String, Long> loginWindow = new ConcurrentHashMap<>();
    // IP → 时间窗口内请求次数
    private final Map<String, Integer> loginCount  = new ConcurrentHashMap<>();

    private final Map<String, Long> apiWindow = new ConcurrentHashMap<>();
    private final Map<String, Integer> apiCount  = new ConcurrentHashMap<>();

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String ip   = getClientIp(request);
        String path = request.getRequestURI();

        if (path.startsWith("/api/auth/login")) {
            // 登录接口：每分钟 10 次
            if (!allow(ip, loginWindow, loginCount, 60_000, 10)) {
                response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value()); // 429
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":429,\"message\":\"请求过于频繁，请稍后再试\",\"data\":null}");
                return;
            }
        } else if (path.startsWith("/api/")) {
            // 其他 API：每秒 30 次
            if (!allow(ip, apiWindow, apiCount, 1_000, 30)) {
                response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":429,\"message\":\"请求过于频繁\",\"data\":null}");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    /** 滑动窗口限流：窗口期内最多 max 次 */
    private boolean allow(String ip, Map<String, Long> window, Map<String, Integer> counter,
                          long windowMs, int max) {
        long now = System.currentTimeMillis();
        Long start = window.get(ip);

        if (start == null || now - start > windowMs) {
            // 新窗口
            window.put(ip, now);
            counter.put(ip, 1);
            return true;
        }

        int count = counter.getOrDefault(ip, 0);
        if (count >= max) {
            return false;
        }

        counter.put(ip, count + 1);
        return true;
    }

    /** 获取真实客户端 IP（考虑代理） */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // X-Forwarded-For 可能包含多个 IP，取第一个
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
