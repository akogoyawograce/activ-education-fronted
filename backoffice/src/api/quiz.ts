import api from './client'
import type {
  QuizResponse,
  QuizRequest,
  QuestionResponse,
  QuestionRequest,
  ReponseResponse,
  ReponseRequest,
  PageResponse,
} from '../types'

export async function getAll(page = 0, size = 10) {
  const response = await api.get<PageResponse<QuizResponse>>('/quiz', {
    params: { page, size },
  })
  return response.data
}

export async function getById(trackingId: string) {
  const response = await api.get<QuizResponse>(`/quiz/${trackingId}`)
  return response.data
}

export async function create(data: QuizRequest) {
  const response = await api.post<QuizResponse>('/quiz', data)
  return response.data
}

export async function update(trackingId: string, data: QuizRequest) {
  const response = await api.put<QuizResponse>(`/quiz/${trackingId}`, data)
  return response.data
}

export async function remove(trackingId: string) {
  await api.delete(`/quiz/${trackingId}`)
}

export async function getQuestions(quizId: string) {
  const response = await api.get<QuestionResponse[]>(`/quiz/${quizId}/questions`)
  return response.data
}

export async function addQuestion(quizId: string, data: QuestionRequest) {
  const response = await api.post<QuestionResponse>(
    `/quiz/${quizId}/questions`,
    data,
  )
  return response.data
}

export async function getReponses(questionId: string) {
  const response = await api.get<ReponseResponse[]>(
    `/questions/${questionId}/reponses`,
  )
  return response.data
}

export async function addReponse(questionId: string, data: ReponseRequest) {
  const response = await api.post<ReponseResponse>(
    `/questions/${questionId}/reponses`,
    data,
  )
  return response.data
}
