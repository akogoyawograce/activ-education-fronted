import api from './client'
import type { PageResponse } from '../types'

export interface KPIs {
  totalEleves: number
  totalConseillers: number
  totalQuiz: number
}

export async function getKPIs(): Promise<KPIs> {
  const [eleves, conseillers, quiz] = await Promise.all([
    api.get<PageResponse<unknown>>('/eleves', { params: { page: 0, size: 1 } }),
    api.get<PageResponse<unknown>>('/conseillers', { params: { page: 0, size: 1 } }),
    api.get<PageResponse<unknown>>('/quiz', { params: { page: 0, size: 1 } }),
  ])

  return {
    totalEleves: eleves.data.totalElements,
    totalConseillers: conseillers.data.totalElements,
    totalQuiz: quiz.data.totalElements,
  }
}
