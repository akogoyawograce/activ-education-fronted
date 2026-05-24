import api from './client'
import type { ParentResponse, ParentRequest, PageResponse } from '../types'

export async function getAll(page = 0, size = 10) {
  const response = await api.get<PageResponse<ParentResponse>>('/parents', {
    params: { page, size },
  })
  return response.data
}

export async function getById(trackingId: string) {
  const response = await api.get<ParentResponse>(`/parents/${trackingId}`)
  return response.data
}

export async function create(data: ParentRequest) {
  const response = await api.post<ParentResponse>('/parents', data)
  return response.data
}

export async function update(trackingId: string, data: ParentRequest) {
  const response = await api.put<ParentResponse>(`/parents/${trackingId}`, data)
  return response.data
}

export async function remove(trackingId: string) {
  await api.delete(`/parents/${trackingId}`)
}

export async function linkEnfant(parentId: string, eleveId: string) {
  const response = await api.post<ParentResponse>(
    `/parents/${parentId}/enfants/${eleveId}`,
  )
  return response.data
}

export async function unlinkEnfant(parentId: string, eleveId: string) {
  const response = await api.delete<ParentResponse>(
    `/parents/${parentId}/enfants/${eleveId}`,
  )
  return response.data
}
