import api from './client'

export interface KPIs {
  totalEleves: number
  totalConseillers: number
  totalQuiz: number
  totalResultats: number
  totalEtablissements: number
}

export interface DateCount {
  date: string
  count: number
}

export interface RDVCount {
  mois: string
  count: number
}

export async function getKPIs(): Promise<KPIs> {
  const response = await api.get<KPIs>('/admin/stats/kpi')
  return response.data
}

export async function getInscriptions(jours = 30): Promise<DateCount[]> {
  const response = await api.get<DateCount[]>('/admin/stats/inscriptions', { params: { jours } })
  return response.data
}

export async function getQuizCompletes(jours = 30): Promise<DateCount[]> {
  const response = await api.get<DateCount[]>('/admin/stats/quiz-completes', { params: { jours } })
  return response.data
}

export async function getRDV(mois = 12): Promise<RDVCount[]> {
  const response = await api.get<RDVCount[]>('/admin/stats/rdv', { params: { mois } })
  return response.data
}

export async function getQuizParDomaine(): Promise<Record<string, number>> {
  const response = await api.get<Record<string, number>>('/admin/stats/quiz-par-domaine')
  return response.data
}
