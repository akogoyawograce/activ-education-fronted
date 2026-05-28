import api from './client'
import type { NotificationResponse } from '../types'

export async function getAll(utilisateurId: string) {
  const response = await api.get<NotificationResponse[]>(
    `/utilisateurs/${utilisateurId}/notifications`,
  )
  return response.data
}

export async function getNonLues(utilisateurId: string) {
  const response = await api.get<NotificationResponse[]>(
    `/utilisateurs/${utilisateurId}/notifications/non-lues`,
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
