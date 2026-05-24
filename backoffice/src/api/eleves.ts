import api from './client'
import type { EleveResponse, EleveRequest, PageResponse, NoteResponse } from '../types'

export async function getAll(page = 0, size = 10) {
  const response = await api.get<PageResponse<EleveResponse>>('/eleves', {
    params: { page, size },
  })
  return response.data
}

export async function getById(trackingId: string) {
  const response = await api.get<EleveResponse>(`/eleves/${trackingId}`)
  return response.data
}

export async function create(data: EleveRequest) {
  const response = await api.post<EleveResponse>('/eleves', data)
  return response.data
}

export async function update(trackingId: string, data: EleveRequest) {
  const response = await api.put<EleveResponse>(`/eleves/${trackingId}`, data)
  return response.data
}

export async function remove(trackingId: string) {
  await api.delete(`/eleves/${trackingId}`)
}

export async function getNotes(eleveTrackingId: string) {
  const response = await api.get<NoteResponse[]>(`/eleves/${eleveTrackingId}/notes`)
  return response.data
}
