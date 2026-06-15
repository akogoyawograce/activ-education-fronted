import axios from 'axios'
import { useAuthStore } from '@/stores/authStore'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api/v1',
})

api.interceptors.request.use((config) => {
  const { accessToken } = useAuthStore.getState()
  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`
  }
  return config
})

let isRefreshing = false
let refreshQueue: Array<{
  resolve: (token: string) => void
  reject: (err: unknown) => void
}> = []

function clearAuthStorage() {
  localStorage.removeItem('refresh_token')
  localStorage.removeItem('user_tracking_id')
  localStorage.removeItem('user_type')
  localStorage.removeItem('user_niveau_acces')
  localStorage.removeItem('user_name')
}

function redirectToLogin() {
  clearAuthStorage()
  useAuthStore.getState().logout()
  window.location.href = '/login'
}

function processQueue(token: string | null, error: unknown = null) {
  refreshQueue.forEach((req) => {
    if (error) req.reject(error)
    else req.resolve(token!)
  })
  refreshQueue = []
}

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config
    const url = originalRequest?.url || ''

    if (!error.response || error.response.status !== 401) {
      return Promise.reject(error)
    }

    if (url.includes('/auth/login') || url.includes('/auth/refresh')) {
      return Promise.reject(error)
    }

    if (originalRequest._retry) {
      redirectToLogin()
      return Promise.reject(error)
    }

    const { refreshToken } = useAuthStore.getState()
    if (!refreshToken) {
      redirectToLogin()
      return Promise.reject(error)
    }

    if (isRefreshing) {
      return new Promise<string>((resolve, reject) => {
        refreshQueue.push({ resolve, reject })
      }).then((token) => {
        originalRequest.headers.Authorization = `Bearer ${token}`
        return api(originalRequest)
      })
    }

    originalRequest._retry = true
    isRefreshing = true

    try {
      const response = await axios.post(`${api.defaults.baseURL}/auth/refresh`, { refreshToken })
      const { accessToken: newAccess, refreshToken: newRefresh } = response.data
      useAuthStore.getState().setTokens(newAccess, newRefresh)
      processQueue(newAccess)
      originalRequest.headers.Authorization = `Bearer ${newAccess}`
      return api(originalRequest)
    } catch (refreshError) {
      processQueue(null, refreshError)
      redirectToLogin()
      return Promise.reject(refreshError)
    } finally {
      isRefreshing = false
    }
  },
)

export default api
