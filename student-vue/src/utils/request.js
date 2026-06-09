import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000
})

// 请求拦截器 — 自动携带 Token
request.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// 响应拦截器 — 统一错误处理
request.interceptors.response.use(
  response => {
    const data = response.data
    // 兼容统一返回格式 { code, message, data }
    if (data.code && data.code !== 200) {
      ElMessage.error(data.message || '请求失败')
      return Promise.reject(new Error(data.message))
    }
    return data.data
  },
  error => {
    if (error.response) {
      const { status } = error.response
      if (status === 401) {
        localStorage.removeItem('token')
        localStorage.removeItem('user')
        router.push('/login')
        ElMessage.error('登录已过期，请重新登录')
      } else if (status === 403) {
        ElMessage.error('权限不足')
      } else {
        ElMessage.error(error.response.data?.message || `请求失败 (${status})`)
      }
    } else {
      ElMessage.error('网络错误，无法连接服务器')
    }
    return Promise.reject(error)
  }
)

// ===================== API 方法 =====================

// Auth
export const login = (data) => request.post('/auth/login', data)
export const getUserInfo = () => request.get('/auth/user-info')

// Student
export const getStudentList = (params) => request.get('/students', { params })
export const getStudentDetail = (id) => request.get(`/students/${id}`)
export const createStudent = (data) => request.post('/students', data)
export const updateStudent = (id, data) => request.put(`/students/${id}`, data)
export const deleteStudent = (id) => request.delete(`/students/${id}`)
export const batchDeleteStudents = (ids) => request.delete('/students/batch', { data: ids })

// Class
export const getClassList = (params) => request.get('/classes', { params })
export const getClassDetail = (id) => request.get(`/classes/${id}`)
export const createClass = (data) => request.post('/classes', data)
export const updateClass = (id, data) => request.put(`/classes/${id}`, data)
export const deleteClass = (id) => request.delete(`/classes/${id}`)

// Course
export const getCourseList = (params) => request.get('/courses', { params })
export const createCourse = (data) => request.post('/courses', data)
export const updateCourse = (id, data) => request.put(`/courses/${id}`, data)
export const deleteCourse = (id) => request.delete(`/courses/${id}`)

// ClassCourse
export const getClassCourseList = (params) => request.get('/class-courses', { params })
export const getClassCoursesByClass = (classId) => request.get(`/class-courses/class/${classId}`)
export const createClassCourse = (data) => request.post('/class-courses', data)
export const updateClassCourse = (id, data) => request.put(`/class-courses/${id}`, data)
export const deleteClassCourse = (id) => request.delete(`/class-courses/${id}`)

// Score
export const getScoreList = (params) => request.get('/scores', { params })
export const saveScore = (data) => request.post('/scores', data)
export const batchSaveScores = (data) => request.post('/scores/batch', data)
export const deleteScore = (id) => request.delete(`/scores/${id}`)
export const getScoreStats = (params) => request.get('/scores/stats', { params })

// User
export const getUserList = (params) => request.get('/users', { params })
export const createUser = (data) => request.post('/users', data)
export const updateUser = (id, data) => request.put(`/users/${id}`, data)
export const deleteUser = (id) => request.delete(`/users/${id}`)
export const getAllRoles = () => request.get('/users/roles')

export default request
