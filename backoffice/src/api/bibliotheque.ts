import api from './client'
import type {
  FicheSerieResponse,
  FicheSerieRequest,
  FicheFiliereResponse,
  FicheFiliereRequest,
  FicheMetierResponse,
  FicheMetierRequest,
  FicheEtablissementResponse,
  FicheEtablissementRequest,
  FAQResponse,
  FAQRequest,
  PageResponse,
} from '../types'

/* ─────────── Séries ─────────── */

export async function getAllSeries(page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheSerieResponse>>(
    '/bibliotheque/series',
    { params: { page, size } },
  )
  return response.data
}

export async function getSerieById(trackingId: string) {
  const response = await api.get<FicheSerieResponse>(
    `/bibliotheque/series/${trackingId}`,
  )
  return response.data
}

export async function createSerie(data: FicheSerieRequest) {
  const response = await api.post<FicheSerieResponse>('/bibliotheque/series', data)
  return response.data
}

export async function updateSerie(trackingId: string, data: FicheSerieRequest) {
  const response = await api.put<FicheSerieResponse>(
    `/bibliotheque/series/${trackingId}`,
    data,
  )
  return response.data
}

export async function deleteSerie(trackingId: string) {
  await api.delete(`/bibliotheque/series/${trackingId}`)
}

export async function searchSeries(motCle: string, page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheSerieResponse>>(
    '/bibliotheque/series/recherche',
    { params: { motCle, page, size } },
  )
  return response.data
}

/* ─────────── Filières ─────────── */

export async function getAllFilieres(page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheFiliereResponse>>(
    '/bibliotheque/filieres',
    { params: { page, size } },
  )
  return response.data
}

export async function getFiliereById(trackingId: string) {
  const response = await api.get<FicheFiliereResponse>(
    `/bibliotheque/filieres/${trackingId}`,
  )
  return response.data
}

export async function createFiliere(data: FicheFiliereRequest) {
  const response = await api.post<FicheFiliereResponse>(
    '/bibliotheque/filieres',
    data,
  )
  return response.data
}

export async function updateFiliere(trackingId: string, data: FicheFiliereRequest) {
  const response = await api.put<FicheFiliereResponse>(
    `/bibliotheque/filieres/${trackingId}`,
    data,
  )
  return response.data
}

export async function deleteFiliere(trackingId: string) {
  await api.delete(`/bibliotheque/filieres/${trackingId}`)
}

export async function searchFilieres(motCle: string, page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheFiliereResponse>>(
    '/bibliotheque/filieres/recherche',
    { params: { motCle, page, size } },
  )
  return response.data
}

/* ─────────── Métiers ─────────── */

export async function getAllMetiers(page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheMetierResponse>>(
    '/bibliotheque/metiers',
    { params: { page, size } },
  )
  return response.data
}

export async function getMetierById(trackingId: string) {
  const response = await api.get<FicheMetierResponse>(
    `/bibliotheque/metiers/${trackingId}`,
  )
  return response.data
}

export async function createMetier(data: FicheMetierRequest) {
  const response = await api.post<FicheMetierResponse>('/bibliotheque/metiers', data)
  return response.data
}

export async function updateMetier(trackingId: string, data: FicheMetierRequest) {
  const response = await api.put<FicheMetierResponse>(
    `/bibliotheque/metiers/${trackingId}`,
    data,
  )
  return response.data
}

export async function deleteMetier(trackingId: string) {
  await api.delete(`/bibliotheque/metiers/${trackingId}`)
}

export async function searchMetiers(motCle: string, page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheMetierResponse>>(
    '/bibliotheque/metiers/recherche',
    { params: { motCle, page, size } },
  )
  return response.data
}

/* ─────────── Établissements ─────────── */

export async function getAllEtablissements(page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheEtablissementResponse>>(
    '/bibliotheque/etablissements',
    { params: { page, size } },
  )
  return response.data
}

export async function getEtablissementById(trackingId: string) {
  const response = await api.get<FicheEtablissementResponse>(
    `/bibliotheque/etablissements/${trackingId}`,
  )
  return response.data
}

export async function createEtablissement(data: FicheEtablissementRequest) {
  const response = await api.post<FicheEtablissementResponse>(
    '/bibliotheque/etablissements',
    data,
  )
  return response.data
}

export async function updateEtablissement(
  trackingId: string,
  data: FicheEtablissementRequest,
) {
  const response = await api.put<FicheEtablissementResponse>(
    `/bibliotheque/etablissements/${trackingId}`,
    data,
  )
  return response.data
}

export async function deleteEtablissement(trackingId: string) {
  await api.delete(`/bibliotheque/etablissements/${trackingId}`)
}

export async function searchEtablissements(motCle: string, page = 0, size = 10) {
  const response = await api.get<PageResponse<FicheEtablissementResponse>>(
    '/bibliotheque/etablissements/recherche',
    { params: { motCle, page, size } },
  )
  return response.data
}

/* ─────────── FAQ ─────────── */

export async function getAllFAQ(page = 0, size = 10) {
  const response = await api.get<PageResponse<FAQResponse>>(
    '/bibliotheque/faq',
    { params: { page, size } },
  )
  return response.data
}

export async function getFAQById(trackingId: string) {
  const response = await api.get<FAQResponse>(`/bibliotheque/faq/${trackingId}`)
  return response.data
}

export async function createFAQ(data: FAQRequest) {
  const response = await api.post<FAQResponse>('/bibliotheque/faq', data)
  return response.data
}

export async function updateFAQ(trackingId: string, data: FAQRequest) {
  const response = await api.put<FAQResponse>(
    `/bibliotheque/faq/${trackingId}`,
    data,
  )
  return response.data
}

export async function deleteFAQ(trackingId: string) {
  await api.delete(`/bibliotheque/faq/${trackingId}`)
}


