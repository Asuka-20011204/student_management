#!/bin/bash
# ============================================================
# 学生管理系统 — 全接口测试脚本
# 使用方式：bash api-test.sh
# 前提：后端已启动（mvn spring-boot:run）
# ============================================================
BASE="http://localhost:8080/api"
PASS=0
FAIL=0

check() {
  local code=$(echo "$1" | grep -o '"code":[0-9]*' | head -1 | cut -d: -f2)
  if [ "$code" = "200" ]; then
    echo "  ✅ PASS  $2"
    ((PASS++))
  else
    echo "  ❌ FAIL  $2  (code=$code)"
    ((FAIL++))
  fi
}

echo ""
echo "══════════════════════════════════════════════"
echo "  学生管理系统 API 测试"
echo "══════════════════════════════════════════════"

# ── 1. 登录 ──
echo ""
echo "── 1. Auth 认证 ──"

echo "  POST /api/auth/login (admin)"
RES=$(curl -s -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}')
check "$RES" "登录 admin"

echo "  POST /api/auth/login (teacher)"
RES=$(curl -s -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"zhang","password":"123456"}')
check "$RES" "登录 zhang（教师）"

echo "  POST /api/auth/login (wrong password)"
RES=$(curl -s -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"wrong"}')
# 期望非200
if echo "$RES" | grep -q '"code":500'; then
  echo "  ✅ PASS  登录错误密码（正确拒绝）"
  ((PASS++))
else
  echo "  ❌ FAIL  登录错误密码"
  ((FAIL++))
fi

# ── 获取 token 供后续测试 ──
TOKEN=$(curl -s -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

AUTH="Authorization: Bearer $TOKEN"

# ── 2. 学生管理 ──
echo ""
echo "── 2. 学生管理 /api/students ──"

echo "  GET 分页查询"
RES=$(curl -s "$BASE/students?page=1&pageSize=3" -H "$AUTH")
check "$RES" "GET 学生分页"

echo "  GET 按姓名搜索"
RES=$(curl -s "$BASE/students?studentNo=2024001&page=1&pageSize=10" -H "$AUTH")
check "$RES" "GET 按姓名搜索"

echo "  GET 按学号搜索"
RES=$(curl -s "$BASE/students?studentNo=2024001&page=1&pageSize=10" -H "$AUTH")
check "$RES" "GET 按学号搜索"

echo "  POST 新增学生"
RES=$(curl -s -X POST "$BASE/students" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"studentNo":"TEST001","name":"TestStudent","gender":1,"classId":1,"phone":"13800000000","status":1}')
check "$RES" "POST 新增学生"

echo "  PUT 编辑学生（需要先查出 id）"
SID=$(echo "$RES" | grep -o '"data":null' > /dev/null && \
  curl -s "$BASE/students?studentNo=TEST001" -H "$AUTH" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
if [ -n "$SID" ]; then
  RES=$(curl -s -X PUT "$BASE/students/$SID" \
    -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"id\":$SID,\"studentNo\":\"TEST001\",\"name\":\"TestUpdate\",\"gender\":1,\"classId\":1,\"status\":1}")
  check "$RES" "PUT 编辑学生 id=$SID"
else
  echo "  ⚠ SKIP  PUT 编辑学生（找不到 TEST001 的 id）"
fi

echo "  DELETE 删除学生"
if [ -n "$SID" ]; then
  RES=$(curl -s -X DELETE "$BASE/students/$SID" -H "$AUTH")
  check "$RES" "DELETE 删除学生 id=$SID"
else
  echo "  ⚠ SKIP  DELETE 删除学生"
fi

# 批量删除测试
echo "  DELETE 批量删除"
RES=$(curl -s -X DELETE "$BASE/students/batch" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '[99999,99998]')
# 批量删除不存在的 id 也应该返回 200
check "$RES" "DELETE 批量删除"

# ── 3. 班级管理 ──
echo ""
echo "── 3. 班级管理 /api/classes ──"

RES=$(curl -s "$BASE/classes?page=1&pageSize=10" -H "$AUTH")
check "$RES" "GET 班级分页"

RES=$(curl -s "$BASE/classes?keyword=2024" -H "$AUTH")
check "$RES" "GET 班级搜索"

RES=$(curl -s -X POST "$BASE/classes" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"className":"TestClass","grade":"2025","room":"T01","description":"for testing"}')
check "$RES" "POST 新增班级"

# ── 4. 课程管理 ──
echo ""
echo "── 4. 课程管理 /api/courses ──"

RES=$(curl -s "$BASE/courses?page=1&pageSize=10" -H "$AUTH")
check "$RES" "GET 课程分页"

RES=$(curl -s -X POST "$BASE/courses" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"courseCode\":\"TS$(date +%s)\",\"courseName\":\"TestCourse\",\"credit\":2.0,\"hours\":32}")
check "$RES" "POST 新增课程"

# ── 5. 排课管理 ──
echo ""
echo "── 5. 排课管理 /api/class-courses ──"

RES=$(curl -s "$BASE/class-courses?page=1&pageSize=10" -H "$AUTH")
check "$RES" "GET 排课分页"

RES=$(curl -s "$BASE/class-courses/class/1" -H "$AUTH")
check "$RES" "GET 按班级查排课 classId=1"

# ── 6. 成绩管理 ──
echo ""
echo "── 6. 成绩管理 /api/scores ──"

RES=$(curl -s "$BASE/scores?page=1&pageSize=5" -H "$AUTH")
check "$RES" "GET 成绩分页"

RES=$(curl -s "$BASE/scores?classId=1" -H "$AUTH")
check "$RES" "GET 成绩按班级筛选"

RES=$(curl -s "$BASE/scores/stats?classId=1&courseId=1" -H "$AUTH")
check "$RES" "GET 成绩统计"

RES=$(curl -s -X POST "$BASE/scores" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"studentId":1,"classCourseId":1,"score":88.5,"examType":"Midterm"}')
check "$RES" "POST 录入成绩"

# ── 7. 用户管理 ──
echo ""
echo "── 7. 用户管理 /api/users ──"

RES=$(curl -s "$BASE/users?page=1&pageSize=10" -H "$AUTH")
check "$RES" "GET 用户分页"

RES=$(curl -s "$BASE/users/roles" -H "$AUTH")
check "$RES" "GET 角色列表"

# ── 8. 401 验证 ──
echo ""
echo "── 8. 安全验证 ──"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/students?page=1&pageSize=3")
if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
  echo "  ✅ PASS  无 Token 访问被拒绝 (HTTP $HTTP_CODE)"
  ((PASS++))
else
  echo "  ❌ FAIL  无 Token 访问应被拒绝 (HTTP $HTTP_CODE)"
  ((FAIL++))
fi

RES=$(curl -s "$BASE/auth/user-info" -H "$AUTH")
check "$RES" "GET 当前用户信息"

# ── 结果 ──
echo ""
echo "══════════════════════════════════════════════"
echo "  测试完成:  $PASS 通过 / $((PASS+FAIL)) 总计"
if [ $FAIL -eq 0 ]; then
  echo "  🎉 全部通过！"
else
  echo "  ⚠ $FAIL 个失败，请检查后端日志"
fi
echo "══════════════════════════════════════════════"
