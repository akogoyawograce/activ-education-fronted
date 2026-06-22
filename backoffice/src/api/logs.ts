import api from './client'

export interface AuditLogEntry {
  id: number
  trackingId: string
  utilisateurEmail: string
  utilisateurNom: string
  action: string
  ressource: string
  details: string
  ip: string
  userAgent: string
  createdAt: string
}

export interface AuditLogPage {
  content: AuditLogEntry[]
  totalElements: number
  totalPages: number
  number: number
  size: number
}

export interface LogFilters {
  email?: string
  action?: string
  fromDate?: string
  toDate?: string
  page?: number
  size?: number
}

export async function getLogs(filters: LogFilters = {}): Promise<AuditLogPage> {
  const response = await api.get<AuditLogPage>('/admin/logs', { params: filters })
  return response.data
}

export async function getLogCounts(): Promise<Record<string, number>> {
  const response = await api.get<Record<string, number>>('/admin/logs/counts')
  return response.data
}
