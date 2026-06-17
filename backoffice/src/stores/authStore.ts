import { create } from 'zustand'
import { login as apiLogin, getMe, refreshToken as apiRefreshToken } from '@/api/auth'
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
  loadFromStorage: () => Promise<void>
  setTokens: (accessToken: string, refreshToken: string) => void
}

export const useAuthStore = create<AuthState>((set, _get) => ({
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

    // Access token stays in memory only — never written to localStorage
    set({
      accessToken: tokenRes.accessToken,
      refreshToken: tokenRes.refreshToken,
      trackingId: tokenRes.trackingId,
      userType,
      niveauAcces,
      userName: null,
      isAuthenticated: true,
    })

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

    set({ niveauAcces, userName: userName || null })
  },

  setTokens: (accessToken: string, refreshToken: string) => {
    localStorage.setItem('refresh_token', refreshToken)
    set({ accessToken, refreshToken })
  },

  logout: () => {
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

  loadFromStorage: async () => {
    const refreshToken = localStorage.getItem('refresh_token')
    const trackingId = localStorage.getItem('user_tracking_id')
    const userType = localStorage.getItem('user_type')
    const niveauAcces = localStorage.getItem('user_niveau_acces')
    const userName = localStorage.getItem('user_name')

    if (!refreshToken || !trackingId || !userType) return

    // Use refresh token to get a new access token (memory only)
    try {
      const tokenRes: TokenResponse = await apiRefreshToken(refreshToken)
      localStorage.setItem('refresh_token', tokenRes.refreshToken)
      set({
        accessToken: tokenRes.accessToken,
        refreshToken: tokenRes.refreshToken,
        trackingId,
        userType,
        niveauAcces,
        userName,
        isAuthenticated: true,
      })
    } catch {
      // Refresh failed — clear everything
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
    }
  },
}))
