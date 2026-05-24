import api from './client'
import type { AdministrateurResponse, AdministrateurRequest, PageResponse } from '../types'

export async function getAll(page = 0, size = 10) {
  const response = await api.get<PageResponse<AdministrateurResponse>>(
    '/administrateurs',
    { params: { page, size } },
  )
  return response.data
}

export async function getById(trackingId: string) {
  const response = await api.get<AdministrateurResponse>(
    `/administrateurs/${trackingId}`,
  )
  return response.data
}

export async function create(data: AdministrateurRequest) {
  const response = await api.post<AdministrateurResponse>('/administrateurs', data)
  return response.data
}

export async function update(trackingId: string, data: AdministrateurRequest) {
  const response = await api.put<AdministrateurResponse>(
    `/administrateurs/${trackingId}`,
    data,
  )
  return response.data
}

export async function remove(trackingId: string) {
  await api.delete(`/administrateurs/${trackingId}`)
}
