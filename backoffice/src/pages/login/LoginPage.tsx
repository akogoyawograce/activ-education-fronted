import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { LogIn, Mail, Lock, Shield } from 'lucide-react'
import { useAuthStore } from '@/stores/authStore'
import logoSrc from '@/assets/logo.jpeg'

function getDashboardPath(userType: string, niveauAcces?: string | null): string {
  if (userType === 'administrateurs') {
    if (niveauAcces === 'SUPER_ADMIN') return '/superadmin/dashboard'
    return '/admin/dashboard'
  }
  if (userType === 'conseillers') return '/conseiller/dashboard'
  return '/login'
}

export default function LoginPage() {
  const navigate = useNavigate()
  const { login: authLogin, completeTotpLogin } = useAuthStore()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [totpStep, setTotpStep] = useState(false)
  const [totpCode, setTotpCode] = useState('')
  const [totpChallenge, setTotpChallenge] = useState('')
  const [totpLoading, setTotpLoading] = useState(false)

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError('')
    if (!email.trim() || !password) {
      setError('Veuillez entrer votre email et mot de passe')
      return
    }
    setLoading(true)
    try {
      const result = await authLogin(email.trim(), password)
      if (result && 'requires2fa' in result && result.requires2fa) {
        setTotpChallenge(result.challengeToken)
        setTotpStep(true)
        return
      }
      const { userType, niveauAcces } = useAuthStore.getState()
      const path = getDashboardPath(userType!, niveauAcces)
      navigate(path, { replace: true })
    } catch (err: unknown) {
      const axiosErr = err as { response?: { status?: number; data?: { message?: string } }; message?: string }
      const status = axiosErr?.response?.status
      if (status === 401) {
        setError('Email ou mot de passe incorrect')
      } else if (status === 429) {
        setError('Trop de tentatives. Réessayez plus tard.')
      } else {
        setError(axiosErr?.response?.data?.message || axiosErr?.message || 'Erreur de connexion')
      }
    } finally {
      setLoading(false)
    }
  }

  const handleTotpSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError('')
    const code = parseInt(totpCode, 10)
    if (isNaN(code) || totpCode.length !== 6) {
      setError('Entrez un code à 6 chiffres')
      return
    }
    setTotpLoading(true)
    try {
      await completeTotpLogin(totpChallenge, code)
      const { userType, niveauAcces } = useAuthStore.getState()
      const path = getDashboardPath(userType!, niveauAcces)
      navigate(path, { replace: true })
    } catch {
      setError('Code invalide. Réessayez.')
    } finally {
      setTotpLoading(false)
    }
  }

  if (totpStep) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary/5 via-background to-primary/10 px-4">
        <div className="w-full max-w-md bg-card rounded-[12px] shadow-lg p-8 border border-border">
          <div className="text-center mb-8">
            <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <Shield className="w-8 h-8 text-primary" />
            </div>
            <h1 className="text-2xl font-bold text-text-main">Double authentification</h1>
            <p className="text-text-secondary mt-1 text-sm">Entrez le code à 6 chiffres de votre application</p>
          </div>
          <form onSubmit={handleTotpSubmit} className="space-y-5">
            <div>
              <input
                type="text"
                inputMode="numeric"
                maxLength={6}
                value={totpCode}
                onChange={(e) => setTotpCode(e.target.value.replace(/\D/g, ''))}
                placeholder="000000"
                className="w-full text-center text-2xl tracking-[8px] py-3 border border-border rounded-lg bg-white text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                autoFocus
              />
            </div>
            {error && (
              <div className="bg-danger-light text-danger text-sm px-4 py-2.5 rounded-lg border border-danger/20">
                {error}
              </div>
            )}
            <button
              type="submit"
              disabled={totpLoading || totpCode.length !== 6}
              className="w-full bg-primary hover:bg-primary-dark text-white font-medium py-2.5 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {totpLoading ? (
                <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                'Vérifier'
              )}
            </button>
            <button
              type="button"
              onClick={() => { setTotpStep(false); setTotpCode(''); setError('') }}
              className="w-full text-sm text-text-secondary hover:text-text-main transition-colors"
            >
              Retour
            </button>
          </form>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary/5 via-background to-primary/10 px-4">
      <div className="w-full max-w-md bg-card rounded-[12px] shadow-lg p-8 border border-border">
        <div className="text-center mb-8">
          <img src={logoSrc} alt="Activ Education" className="h-14 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-text-main">Activ Education</h1>
          <p className="text-text-secondary mt-1 text-sm">Backoffice — Connexion</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1.5">Email</label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-secondary" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="ex: email@exemple.com"
                className="w-full pl-10 pr-3 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                autoFocus
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-text-main mb-1.5">Mot de passe</label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-secondary" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Mot de passe"
                className="w-full pl-10 pr-3 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>

          {error && (
            <div className="bg-danger-light text-danger text-sm px-4 py-2.5 rounded-lg border border-danger/20">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-primary hover:bg-primary-dark text-white font-medium py-2.5 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {loading ? (
              <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <>
                <LogIn className="w-4 h-4" />
                Se connecter
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  )
}
