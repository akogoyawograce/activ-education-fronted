import api from './client'
import type { ScoreMatriceResponse, ScoreMatriceRequest } from '@/types'

export async function getAll() {
  const response = await api.get<ScoreMatriceResponse[]>('/score-matrices')
  return response.data
}

export async function getById(id: string) {
  const response = await api.get<ScoreMatriceResponse>(`/score-matrices/${id}`)
  return response.data
}

export async function create(data: ScoreMatriceRequest) {
  const response = await api.post<ScoreMatriceResponse>('/score-matrices', data)
  return response.data
}

export async function update(id: string, data: ScoreMatriceRequest) {
  const response = await api.put<ScoreMatriceResponse>(`/score-matrices/${id}`, data)
  return response.data
}

export async function remove(id: string) {
  await api.delete(`/score-matrices/${id}`)
}
