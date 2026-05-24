import api from './client'
import type { LoginRequest, TokenResponse } from '@/types'

export async function login(email: string, password: string): Promise<TokenResponse> {
  const body: LoginRequest = { email, motDePasse: password }
  const response = await api.post('/auth/login', body)
  return response.data
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function getMe(): Promise<Record<string, any>> {
  const response = await api.get('/auth/me')
  return response.data
}

export async function refreshToken(refreshToken: string): Promise<TokenResponse> {
  const response = await api.post('/auth/refresh', { refreshToken })
  return response.data
}
