import api from './client'
import type { RendezVousResponse, RendezVousRequest } from '../types'

export async function getByConseiller(conseillerId: string) {
  const response = await api.get<RendezVousResponse[]>(
    `/rendez-vous/conseiller/${conseillerId}`,
  )
  return response.data
}

export async function getByEleve(eleveId: string) {
  const response = await api.get<RendezVousResponse[]>(
    `/rendez-vous/eleve/${eleveId}`,
  )
  return response.data
}

export async function create(data: RendezVousRequest) {
  const response = await api.post<RendezVousResponse>('/rendez-vous', data)
  return response.data
}

export async function annuler(trackingId: string) {
  const response = await api.patch<RendezVousResponse>(
    `/rendez-vous/${trackingId}/annuler`,
  )
  return response.data
}

export async function terminer(trackingId: string) {
  const response = await api.patch<RendezVousResponse>(
    `/rendez-vous/${trackingId}/terminer`,
  )
  return response.data
}


