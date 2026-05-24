import { Bell, UserCircle } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAuthStore } from '@/stores/authStore'

export default function Header() {
  const { userName, userType, niveauAcces } = useAuthStore()
  const navigate = useNavigate()

  const profilPath = userType === 'conseillers' ? '/conseiller/profil'
    : niveauAcces === 'SUPER_ADMIN' ? '/superadmin/profil'
    : '/admin/profil'

  return (
    <header className="fixed top-0 left-[240px] right-0 h-[60px] bg-card border-b border-border flex items-center justify-between px-6 z-20">
      <div />

      <div className="flex items-center gap-4">
        <button
          onClick={() => navigate(profilPath)}
          className="relative p-2 rounded-lg text-text-secondary hover:text-text-main hover:bg-gray-100 transition-colors"
          title="Notifications"
        >
          <Bell className="w-5 h-5" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-danger rounded-full" />
        </button>
        <button
          onClick={() => navigate(profilPath)}
          className="flex items-center gap-2.5 border-l border-border pl-4 hover:opacity-80 transition-opacity"
        >
          <UserCircle className="w-8 h-8 text-text-secondary" />
          <span className="text-sm font-medium text-text-main">{userName || 'Utilisateur'}</span>
        </button>
      </div>
    </header>
  )
}
