import { useEffect } from 'react'
import { Outlet, useNavigate } from 'react-router-dom'
import Sidebar from './Sidebar'
import Header from './Header'
import { useAuthStore } from '@/stores/authStore'

export default function AppLayout() {
  const navigate = useNavigate()
  const { isAuthenticated, loadFromStorage } = useAuthStore()

  useEffect(() => {
    loadFromStorage()
  }, [loadFromStorage])

  useEffect(() => {
    if (!useAuthStore.getState().isAuthenticated) {
      navigate('/login', { replace: true })
    }
  }, [navigate, isAuthenticated])

  if (!useAuthStore.getState().isAuthenticated) {
    return null
  }

  return (
    <div className="min-h-screen bg-background">
      <Sidebar />
      <Header />
      <main className="ml-[240px] pt-[60px] p-6 min-h-screen">
        <Outlet />
      </main>
    </div>
  )
}
