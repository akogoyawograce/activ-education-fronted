import api from './client'
import type { SeuilAdmissionResponse, SeuilAdmissionRequest } from '../types'

export async function getByFiliere(filiereId: string) {
  const response = await api.get<SeuilAdmissionResponse[]>(
    `/filieres/${filiereId}/seuils-admission`,
  )
  return response.data
}

export async function getAll() {
  return [] as SeuilAdmissionResponse[]
}

export async function create(data: SeuilAdmissionRequest) {
  const response = await api.post<SeuilAdmissionResponse>('/seuils-admission', data)
  return response.data
}

export async function update(id: string, data: SeuilAdmissionRequest) {
  const response = await api.put<SeuilAdmissionResponse>(
    `/seuils-admission/${id}`,
    data,
  )
  return response.data
}

export async function remove(id: string) {
  await api.delete(`/seuils-admission/${id}`)
}
