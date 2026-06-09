import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('@/views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/Dashboard.vue'),
        meta: { title: '首页', icon: 'HomeFilled' }
      },
      {
        path: 'students',
        name: 'Students',
        component: () => import('@/views/student/StudentList.vue'),
        meta: { title: '学生管理', icon: 'UserFilled' }
      },
      {
        path: 'classes',
        name: 'Classes',
        component: () => import('@/views/class/ClassList.vue'),
        meta: { title: '班级管理', icon: 'OfficeBuilding' }
      },
      {
        path: 'courses',
        name: 'Courses',
        component: () => import('@/views/course/CourseList.vue'),
        meta: { title: '课程管理', icon: 'Notebook' }
      },
      {
        path: 'class-courses',
        name: 'ClassCourses',
        component: () => import('@/views/classcourse/ClassCourseList.vue'),
        meta: { title: '排课管理', icon: 'Grid' }
      },
      {
        path: 'scores',
        name: 'Scores',
        component: () => import('@/views/score/ScoreManage.vue'),
        meta: { title: '成绩管理', icon: 'DataAnalysis' }
      },
      {
        path: 'teachers',
        name: 'Teachers',
        component: () => import('@/views/user/UserList.vue'),
        meta: { title: '教师管理', icon: 'User', roles: ['ROLE_ADMIN'] }
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/user/UserList.vue'),
        meta: { title: '用户管理', icon: 'Setting', roles: ['ROLE_ADMIN'] }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.path !== '/login' && !token) {
    next('/login')
  } else if (to.path === '/login' && token) {
    next('/')
  } else {
    next()
  }
})

export default router
