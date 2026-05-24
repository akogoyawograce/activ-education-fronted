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

    let userName = userType || ''
    try {
      const me = await getMe()
      const fullName = `${me.prenom || ''} ${me.nom || ''}`.trim()
      if (fullName) userName = fullName
    } catch {
      // keep fallback userName = userType
    }

    // niveauAcces is in /administrateurs/{id}, not in /auth/me
    if (!niveauAcces && userType === 'administrateurs' && tokenRes.trackingId) {
      try {
        const admin = await getAdmin(tokenRes.trackingId)
        if (admin.niveauAcces) niveauAcces = admin.niveauAcces
      } catch {
        // keep fallback
      }
    }

    localStorage.setItem('access_token', tokenRes.accessToken)
    localStorage.setItem('refresh_token', tokenRes.refreshToken)
    localStorage.setItem('user_tracking_id', tokenRes.trackingId)
    localStorage.setItem('user_type', userType)
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
