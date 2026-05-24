import { useEffect, useState } from 'react'
import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { ShieldAlert } from 'lucide-react'
import { useAuthStore } from '@/stores/authStore'

interface ProtectedRouteProps {
  allowedRoles?: string[]
}

function canAccess(
  userType: string | null,
  niveauAcces: string | null,
  allowedRoles?: string[]
): boolean {
  if (!userType) return false
  if (!allowedRoles || allowedRoles.length === 0) return true
  return allowedRoles.some((role) => {
    if (role === 'SUPER_ADMIN') return niveauAcces === 'SUPER_ADMIN'
    if (role === 'ADMIN') return userType === 'administrateurs' && niveauAcces !== 'SUPER_ADMIN'
    if (role === 'CONSEILLER') return userType === 'conseillers'
    return false
  })
}

function getUserRoleLabel(userType: string | null, niveauAcces: string | null): string {
  if (!userType) return ''
  if (userType === 'conseillers') return 'Conseiller'
  if (niveauAcces === 'SUPER_ADMIN') return 'Super Administrateur'
  if (niveauAcces === 'MODERATEUR') return 'Modérateur'
  if (niveauAcces === 'GESTIONNAIRE_CONSEILLER') return 'Gestionnaire de conseillers'
  return 'Administrateur'
}

export default function ProtectedRoute({ allowedRoles }: ProtectedRouteProps) {
  const location = useLocation()
  const { isAuthenticated, userType, niveauAcces, loadFromStorage } = useAuthStore()
  const [ready, setReady] = useState(false)

  useEffect(() => {
    loadFromStorage()
    setReady(true)
  }, [loadFromStorage])

  if (!ready) return null

  const storedToken = localStorage.getItem('access_token')
  const effectiveAuth = isAuthenticated || !!storedToken

  if (!effectiveAuth) {
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  if (allowedRoles && !canAccess(userType, niveauAcces, allowedRoles)) {
    const roleLabel = getUserRoleLabel(userType, niveauAcces)
    return (
      <div className="min-h-screen flex items-center justify-center bg-background p-8">
        <div className="text-center max-w-md">
          <div className="w-16 h-16 bg-danger-light rounded-full flex items-center justify-center mx-auto mb-5">
            <ShieldAlert className="w-8 h-8 text-danger" />
          </div>
          <h1 className="text-2xl font-bold text-text-main mb-2">Accès refusé</h1>
          <p className="text-text-secondary mb-1">
            Vous n'avez pas les permissions nécessaires pour accéder à cette page.
          </p>
          <p className="text-sm text-text-secondary">
            Votre rôle actuel : <span className="font-medium text-text-main">{roleLabel}</span>
          </p>
        </div>
      </div>
    )
  }

  return <Outlet />
}
