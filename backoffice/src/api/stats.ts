import api from './client'

export interface KPIs {
  totalEleves: number
  totalConseillers: number
  totalQuiz: number
}

export async function getKPIs(): Promise<KPIs> {
  const response = await api.get<KPIs>('/admin/stats/kpi')
  return response.data
}
