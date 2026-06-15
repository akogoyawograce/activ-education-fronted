import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { ArrowLeft, Plus, GripVertical } from 'lucide-react'
import * as quizService from '@/api/quiz'
import type { QuestionResponse } from '@/types'
import { QuestionForm } from './QuizEditorPageForm'

export default function QuizEditorPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const [selectedIdx, setSelectedIdx] = useState<number | null>(null)

  const { data: quiz, isLoading: quizLoading } = useQuery({
    queryKey: ['quiz', id],
    queryFn: () => quizService.getById(id!),
    enabled: !!id,
  })

  const { data: fetchedQuestions, isLoading: questionsLoading } = useQuery({
    queryKey: ['quiz-questions', id],
    queryFn: () => quizService.getQuestions(id!),
    enabled: !!id,
  })

  const questions = fetchedQuestions ?? []

  const addQuestionMutation = useMutation({
    mutationFn: () =>
      quizService.addQuestion(id!, {
        texteQuestion: '',
        ordre: questions.length + 1,
      }),
    onSuccess: (newQ) => {
      queryClient.setQueryData<QuestionResponse[]>(['quiz-questions', id], (old) => [...(old ?? []), newQ])
      setSelectedIdx(questions.length)
    },
  })

  const saveQuestionMutation = useMutation({
    mutationFn: async (formData: {
      texteQuestion: string
      domaine: string
      difficulte: number
      tags: string
      typeQuestion: string
      niveauCible: string
    }) => {
      if (selectedIdx === null || !questions[selectedIdx]) return
      const q = questions[selectedIdx]
      await quizService.updateQuestion(q.trackingId, {
        texteQuestion: formData.texteQuestion,
        ordre: q.ordre,
        niveauCible: formData.niveauCible || undefined,
        domaine: formData.domaine || undefined,
        difficulte: formData.difficulte,
        tags: formData.tags || undefined,
        typeQuestion: formData.typeQuestion,
      })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['quiz-questions', id] })
    },
  })

  const addReponseMutation = useMutation({
    mutationFn: async (questionId: string) => {
      const rep = await quizService.addReponse(questionId, { texteReponse: '' })
      return rep
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['quiz-questions', id] })
    },
  })

  const updateReponseMutation = useMutation({
    mutationFn: async ({ id, texte }: { id: string; texte: string }) => {
      await quizService.updateReponse(id, { texteReponse: texte })
    },
  })

  const removeReponseMutation = useMutation({
    mutationFn: async (id: string) => {
      await quizService.removeReponse(id)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['quiz-questions', id] })
    },
  })

  if (quizLoading || questionsLoading) {
    return (
      <div className="space-y-6">
        <div className="h-8 bg-gray-200 rounded w-64 animate-pulse" />
        <div className="grid grid-cols-[320px_1fr] gap-6 items-start">
          <div className="h-96 bg-gray-200 rounded-[12px] animate-pulse" />
          <div className="h-96 bg-gray-200 rounded-[12px] animate-pulse" />
        </div>
      </div>
    )
  }

  const selectedQuestion = selectedIdx !== null ? questions[selectedIdx] : null

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <button
          onClick={() => navigate('/admin/quiz')}
          className="p-2 rounded-lg hover:bg-gray-100 transition-colors text-text-secondary"
        >
          <ArrowLeft className="size-5" />
        </button>
        <div>
          <h1 className="text-xl font-semibold text-text-main">
            {quiz?.titre ?? 'Éditeur de quiz'}
          </h1>
          <p className="text-sm text-text-secondary">
            {questions.length} question{questions.length !== 1 ? 's' : ''}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-[320px_1fr] gap-6 items-start">
        <div className="bg-card rounded-[12px] border border-border p-4 space-y-2">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-semibold text-text-main">Questions</h2>
            <button
              onClick={() => addQuestionMutation.mutate()}
              disabled={addQuestionMutation.isPending}
              className="text-primary hover:bg-primary-light p-1.5 rounded-lg transition-colors"
            >
              <Plus className="size-4" />
            </button>
          </div>

          {questions.length === 0 ? (
            <p className="text-sm text-text-secondary text-center py-8">
              Aucune question. Cliquez sur + pour ajouter.
            </p>
          ) : (
            questions.map((q, idx) => (
              <button
                key={q.trackingId}
                onClick={() => setSelectedIdx(idx)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-left transition-colors ${
                  selectedIdx === idx
                    ? 'bg-primary-light text-primary font-medium'
                    : 'text-text-main hover:bg-gray-50'
                }`}
              >
                <GripVertical className="size-4 shrink-0 text-text-secondary" />
                <span className="truncate">
                  Q{idx + 1}. {q.texteQuestion || '(vide)'}
                </span>
              </button>
            ))
          )}
        </div>

        {selectedQuestion ? (
          <QuestionForm
            key={selectedQuestion.trackingId}
            question={selectedQuestion}
            onSave={saveQuestionMutation.mutate}
            onAddOption={addReponseMutation.mutate}
            onUpdateOption={({ id, texte }: { id: string; texte: string }) =>
              updateReponseMutation.mutate({ id, texte })
            }
            onRemoveOption={removeReponseMutation.mutate}
          />
        ) : (
          <div className="bg-card rounded-[12px] border border-border p-5">
            <div className="flex flex-col items-center justify-center py-16 text-text-secondary">
              <ArrowLeft className="size-10 mb-3 text-gray-300" />
              <p className="text-sm">
                Sélectionnez une question dans la liste pour l'éditer
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
