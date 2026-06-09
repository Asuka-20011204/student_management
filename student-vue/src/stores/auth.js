import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi, getUserInfo } from '@/utils/request'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || '')
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))

  const isLoggedIn = computed(() => !!token.value)
  const roles = computed(() => user.value?.roles || [])
  const isAdmin = computed(() => roles.value.includes('ROLE_ADMIN'))
  const isTeacher = computed(() => roles.value.includes('ROLE_TEACHER'))

  async function login(username, password) {
    const res = await loginApi({ username, password })
    token.value = res.token
    user.value = {
      userId: res.userId,
      username: res.username,
      realName: res.realName,
      roles: res.roles
    }
    localStorage.setItem('token', res.token)
    localStorage.setItem('user', JSON.stringify(user.value))
    return res
  }

  async function fetchUserInfo() {
    const res = await getUserInfo()
    user.value = { ...user.value, ...res }
  }

  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  return { token, user, isLoggedIn, roles, isAdmin, isTeacher, login, fetchUserInfo, logout }
})
