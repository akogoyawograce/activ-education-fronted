import { create } from 'zustand'
import { login as apiLogin, getMe } from '@/api/auth'
import { getById as getAdmin } from '@/api/administrateurs'
import type { TokenResponse } from '@/types'

const TYPE_MAP: Record<string, string> = {
  ADMINISTRATEUR: 'administrateurs',
  CONSEILLER: 'conseillers',
  ELEVE: 'eleves',
  PARENT: 'parents',
}

const ROLE_TO_NIVEAU: Record<string, string> = {
  ROLE_SUPER_ADMIN: 'SUPER_ADMIN',
  ROLE_MODERATEUR: 'MODERATEUR',
  ROLE_GESTIONNAIRE_CONSEILLER: 'GESTIONNAIRE_CONSEILLER',
}

interface AuthState {
  accessToken: string | null
  refreshToken: string | null
  trackingId: string | null
  userType: string | null
  niveauAcces: string | null
  userName: string | null
  isAuthenticated: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  loadFromStorage: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  accessToken: null,
  refreshToken: null,
  trackingId: null,
  userType: null,
  niveauAcces: null,
  userName: null,
  isAuthenticated: false,

  login: async (email: string, password: string) => {
    const tokenRes: TokenResponse = await apiLogin(email, password)
    const userType = TYPE_MAP[tokenRes.typeUtilisateur.toUpperCase()] || tokenRes.typeUtilisateur.toLowerCase()

    let niveauAcces: string | null = null
    for (const role of tokenRes.roles) {
      const mapped = ROLE_TO_NIVEAU[role]
      if (mapped) {
        niveauAcces = mapped
        break
      }
    }

    // Save access_token FIRST so subsequent API calls use the new token
    localStorage.setItem('access_token', tokenRes.accessToken)
    localStorage.setItem('refresh_token', tokenRes.refreshToken)
    localStorage.setItem('user_tracking_id', tokenRes.trackingId)
    localStorage.setItem('user_type', userType)

    let userName = userType || ''
    const [meResult, adminResult] = await Promise.allSettled([
      getMe(),
      !niveauAcces && userType === 'administrateurs' && tokenRes.trackingId
        ? getAdmin(tokenRes.trackingId)
        : Promise.resolve(null),
    ])
    if (meResult.status === 'fulfilled') {
      const fullName = `${meResult.value.prenom || ''} ${meResult.value.nom || ''}`.trim()
      if (fullName) userName = fullName
    }
    if (adminResult.status === 'fulfilled' && adminResult.value?.niveauAcces) {
      niveauAcces = adminResult.value.niveauAcces
    }

    if (niveauAcces) localStorage.setItem('user_niveau_acces', niveauAcces)
    if (userName) localStorage.setItem('user_name', userName)

    set({
      accessToken: tokenRes.accessToken,
      refreshToken: tokenRes.refreshToken,
      trackingId: tokenRes.trackingId,
      userType,
      niveauAcces,
      userName: userName || null,
      isAuthenticated: true,
    })
  },

  logout: () => {
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    localStorage.removeItem('user_tracking_id')
    localStorage.removeItem('user_type')
    localStorage.removeItem('user_niveau_acces')
    localStorage.removeItem('user_name')
    set({
      accessToken: null,
      refreshToken: null,
      trackingId: null,
      userType: null,
      niveauAcces: null,
      userName: null,
      isAuthenticated: false,
    })
  },

  loadFromStorage: () => {
    const accessToken = localStorage.getItem('access_token')
    const trackingId = localStorage.getItem('user_tracking_id')
    const userType = localStorage.getItem('user_type')
    const niveauAcces = localStorage.getItem('user_niveau_acces')
    const userName = localStorage.getItem('user_name')
    if (accessToken && trackingId && userType) {
      set({
        accessToken,
        refreshToken: localStorage.getItem('refresh_token'),
        trackingId,
        userType,
        niveauAcces,
        userName,
        isAuthenticated: true,
      })
    }
  },
}))
