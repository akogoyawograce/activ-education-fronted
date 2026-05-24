import api from './client'
import type { ConseillerResponse, ConseillerRequest, PageResponse } from '../types'

export async function getAll(page = 0, size = 10) {
  const response = await api.get<PageResponse<ConseillerResponse>>('/conseillers', {
    params: { page, size },
  })
  return response.data
}

export async function getById(trackingId: string) {
  const response = await api.get<ConseillerResponse>(`/conseillers/${trackingId}`)
  return response.data
}

export async function create(data: ConseillerRequest) {
  const response = await api.post<ConseillerResponse>('/conseillers', data)
  return response.data
}

export async function update(trackingId: string, data: ConseillerRequest) {
  const response = await api.put<ConseillerResponse>(`/conseillers/${trackingId}`, data)
  return response.data
}

export async function remove(trackingId: string) {
  await api.delete(`/conseillers/${trackingId}`)
}

export async function getDisponibles(seuil = 10) {
  const response = await api.get<ConseillerResponse[]>('/conseillers/disponibles', {
    params: { seuil },
  })
  return response.data
}
