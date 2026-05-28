import api from './client'
import type { NotificationResponse, PageResponse } from '../types'

export async function getAll(utilisateurId: string) {
  const response = await api.get<NotificationResponse[]>(
    `/utilisateurs/${utilisateurId}/notifications`,
  )
  return response.data
}

export async function getAllPagine(utilisateurId: string, page = 0, size = 10) {
  const response = await api.get<PageResponse<NotificationResponse>>(
    `/utilisateurs/${utilisateurId}/notifications/pagine`,
    { params: { page, size } },
  )
  return response.data
}

export async function getById(notificationId: string) {
  const response = await api.get<NotificationResponse>(
    `/notifications/${notificationId}`,
  )
  return response.data
}

export async function getNonLues(utilisateurId: string) {
  const response = await api.get<NotificationResponse[]>(
    `/utilisateurs/${utilisateurId}/notifications/non-lues`,
  )
  return response.data
}

export async function sendNotification(utilisateurId: string, titre: string, message: string) {
  const response = await api.post<NotificationResponse>(
    `/utilisateurs/${utilisateurId}/notifications`,
    { titre, message },
  )
  return response.data
}

export async function markAsRead(notificationId: string) {
  await api.patch(`/notifications/${notificationId}/lire`)
}

export async function markAllAsRead(utilisateurId: string) {
  await api.patch(`/utilisateurs/${utilisateurId}/notifications/tout-lire`)
}

export async function remove(notificationId: string) {
  await api.delete(`/notifications/${notificationId}`)
}
