import api from './client'
import type { MessageResponse, MessageRequest, PageResponse, NombreNonLusResponse } from '../types'

export async function getRecus(destinataireId: string, page = 0, size = 10) {
  const response = await api.get<PageResponse<MessageResponse>>(
    `/utilisateurs/${destinataireId}/messages/recus`,
    { params: { page, size } },
  )
  return response.data
}

export async function getEnvoyes(expediteurId: string, page = 0, size = 10) {
  const response = await api.get<PageResponse<MessageResponse>>(
    `/utilisateurs/${expediteurId}/messages/envoyes`,
    { params: { page, size } },
  )
  return response.data
}

export async function send(expediteurId: string, data: MessageRequest) {
  const response = await api.post<MessageResponse>(
    `/utilisateurs/${expediteurId}/messages`,
    data,
  )
  return response.data
}

export async function getConversation(user1: string, user2: string) {
  const response = await api.get<MessageResponse[]>('/messages/conversation', {
    params: { user1, user2 },
  })
  return response.data
}

export async function getNonLus(destinataireId: string) {
  const response = await api.get<NombreNonLusResponse>(
    `/utilisateurs/${destinataireId}/messages/non-lus/compteur`,
  )
  return response.data
}

export async function markAsRead(expediteur: string, destinataire: string) {
  await api.patch('/messages/conversation/lire', null, {
    params: { expediteur, destinataire },
  })
}

export async function removeMessage(trackingId: string) {
  await api.delete(`/messages/${trackingId}`)
}
