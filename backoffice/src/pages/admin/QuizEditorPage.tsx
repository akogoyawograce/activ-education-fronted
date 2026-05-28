import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { ArrowLeft, Plus, Trash2, Save, GripVertical } from 'lucide-react'
import * as quizService from '@/api/quiz'
import type { QuestionResponse, ReponseResponse } from '@/types'

const DOMAINES = [
  'Sciences', 'Lettres', 'Langues', 'Technique', 'Arts',
  'Sport', 'Sciences Humaines', 'Commerce', 'Administration',
]

const TYPES_QUESTION = [
  { value: 'RIASEC', label: 'RIASEC' },
  { value: 'CONNAISSANCE', label: 'Connaissance' },
  { value: 'INTERET', label: 'Intérêt' },
  { value: 'PERSONNALITE', label: 'Personnalité' },
]

const NIVEAUX = [
  { value: '', label: 'Tous niveaux' },
  { value: 'Ecolier', label: 'Écolier' },
  { value: 'Collégien', label: 'Collégien' },
  { value: 'Lycéen', label: 'Lycéen' },
  { value: 'Étudiant', label: 'Étudiant' },
  { value: 'Professionnel', label: 'Professionnel' },
]

interface OptionItem {
  id: string
  texte: string
  categoriePoint?: string
  points?: number
}

export default function QuizEditorPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const [questions, setQuestions] = useState<QuestionResponse[]>([])
  const [selectedIdx, setSelectedIdx] = useState<number | null>(null)
  const [questionText, setQuestionText] = useState('')
  const [domaine, setDomaine] = useState('')
  const [difficulte, setDifficulte] = useState(1)
  const [tags, setTags] = useState('')
  const [typeQuestion, setTypeQuestion] = useState('RIASEC')
  const [niveauCible, setNiveauCible] = useState('')
  const [options, setOptions] = useState<OptionItem[]>([])

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

  useEffect(() => {
    if (fetchedQuestions) {
      setQuestions(fetchedQuestions)
    }
  }, [fetchedQuestions])

  useEffect(() => {
    if (selectedIdx !== null && questions[selectedIdx]) {
      const q = questions[selectedIdx]
      setQuestionText(q.texteQuestion)
      setDomaine(q.domaine ?? '')
      setDifficulte(q.difficulte ?? 1)
      setTags(q.tags ?? '')
      setTypeQuestion(q.typeQuestion ?? 'RIASEC')
      setNiveauCible(q.niveauCible ?? '')
      loadOptions(q.trackingId)
    } else {
      setQuestionText('')
      setDomaine('')
      setDifficulte(1)
      setTags('')
      setTypeQuestion('RIASEC')
      setNiveauCible('')
      setOptions([])
    }
  }, [selectedIdx, questions])

  async function loadOptions(questionId: string) {
    try {
      const reps = await quizService.getReponses(questionId)
      setOptions(
        reps.map((r: ReponseResponse) => ({
          id: r.trackingId,
          texte: r.texteReponse,
          categoriePoint: r.categoriePoint,
          points: r.points,
        })),
      )
    } catch {
      setOptions([])
    }
  }

  const addQuestionMutation = useMutation({
    mutationFn: () =>
      quizService.addQuestion(id!, {
        texteQuestion: '',
        ordre: questions.length + 1,
      }),
    onSuccess: (newQ) => {
      setQuestions((prev) => [...prev, newQ])
      queryClient.invalidateQueries({ queryKey: ['quiz-questions', id] })
      setSelectedIdx(questions.length)
    },
  })

  const saveQuestionMutation = useMutation({
    mutationFn: async () => {
      if (selectedIdx === null || !questions[selectedIdx]) return
      const q = questions[selectedIdx]
      await quizService.updateQuestion(q.trackingId, {
        texteQuestion: questionText,
        ordre: q.ordre,
        niveauCible: niveauCible || undefined,
        domaine: domaine || undefined,
        difficulte: difficulte,
        tags: tags || undefined,
        typeQuestion: typeQuestion,
      })
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

  const addReponseMutation = useMutation({
    mutationFn: async (questionId: string) => {
      const rep = await quizService.addReponse(questionId, { texteReponse: '' })
      return rep
    },
    onSuccess: (rep) => {
      setOptions((prev) => [...prev, { id: rep.trackingId, texte: rep.texteReponse, categoriePoint: rep.categoriePoint, points: rep.points }])
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
    onSuccess: (_data, id) => {
      setOptions((prev) => prev.filter((o) => o.id !== id))
    },
  })

  function addOption() {
    if (selectedIdx === null) return
    const q = questions[selectedIdx]
    addReponseMutation.mutate(q.trackingId)
  }

  function updateOption(id: string, texte: string) {
    setOptions((prev) =>
      prev.map((o) => (o.id === id ? { ...o, texte } : o)),
    )
    updateReponseMutation.mutate({ id, texte })
  }

  function removeOption(id: string) {
    removeReponseMutation.mutate(id)
  }

  const selectedQuestion =
    selectedIdx !== null ? questions[selectedIdx] : null

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

        <div className="bg-card rounded-[12px] border border-border p-5">
          {selectedQuestion ? (
            <div className="space-y-5">
              <h2 className="text-sm font-semibold text-text-main">
                Question Q{(selectedIdx ?? 0) + 1}
              </h2>

              <div>
                <label className="block text-sm font-medium text-text-main mb-1">
                  Texte de la question
                </label>
                <textarea
                  rows={3}
                  value={questionText}
                  onChange={(e) => {
                    setQuestionText(e.target.value)
                    setQuestions((prev) =>
                      prev.map((q, i) =>
                        i === selectedIdx
                          ? { ...q, texteQuestion: e.target.value }
                          : q,
                      ),
                    )
                  }}
                  placeholder="Saisissez votre question..."
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-text-main mb-1">Type de question</label>
                  <select
                    value={typeQuestion}
                    onChange={(e) => setTypeQuestion(e.target.value)}
                    className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary bg-white"
                  >
                    {TYPES_QUESTION.map((t) => (
                      <option key={t.value} value={t.value}>{t.label}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-text-main mb-1">Domaine</label>
                  <select
                    value={domaine}
                    onChange={(e) => setDomaine(e.target.value)}
                    className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary bg-white"
                  >
                    <option value="">Sélectionner...</option>
                    {DOMAINES.map((d) => (
                      <option key={d} value={d}>{d}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-text-main mb-1">Difficulté (1-5)</label>
                  <input
                    type="number"
                    min={1}
                    max={5}
                    value={difficulte}
                    onChange={(e) => setDifficulte(Number(e.target.value))}
                    className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-text-main mb-1">Niveau cible</label>
                  <select
                    value={niveauCible}
                    onChange={(e) => setNiveauCible(e.target.value)}
                    className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary bg-white"
                  >
                    {NIVEAUX.map((n) => (
                      <option key={n.value} value={n.value}>{n.label}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-text-main mb-1">Tags (séparés par des virgules)</label>
                <input
                  type="text"
                  value={tags}
                  onChange={(e) => setTags(e.target.value)}
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  placeholder="science, biologie, ADN"
                />
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <label className="text-sm font-medium text-text-main">
                    Options de réponse
                  </label>
                  <button
                    onClick={addOption}
                    className="text-xs font-medium text-primary hover:bg-primary-light px-2.5 py-1 rounded-lg transition-colors flex items-center gap-1"
                  >
                    <Plus className="size-3" />
                    Ajouter une option
                  </button>
                </div>

                {options.length === 0 ? (
                  <p className="text-sm text-text-secondary text-center py-4 border border-dashed border-border rounded-lg">
                    Aucune option. Ajoutez-en une.
                  </p>
                ) : (
                  <div className="space-y-2">
                    {options.map((opt) => (
                      <div key={opt.id} className="flex items-center gap-2">
                        <input
                          type="text"
                          value={opt.texte}
                          onChange={(e) =>
                            updateOption(opt.id, e.target.value)
                          }
                          placeholder="Option..."
                          className="flex-1 px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                        />
                        <select
                          value={opt.categoriePoint ?? ''}
                          onChange={(e) => {
                            setOptions((prev) =>
                              prev.map((o) => (o.id === opt.id ? { ...o, categoriePoint: e.target.value || undefined } : o)),
                            )
                          }}
                          className="w-28 px-2 py-2 border border-border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary bg-white"
                        >
                          <option value="">Catégorie</option>
                          <option value="R">R (Réaliste)</option>
                          <option value="I">I (Investigateur)</option>
                          <option value="A">A (Artistique)</option>
                          <option value="S">S (Social)</option>
                          <option value="E">E (Entrepreneur)</option>
                          <option value="C">C (Conventionnel)</option>
                          <option value="NON_RENSEIGNE">Non renseigné</option>
                        </select>
                        <button
                          onClick={() => removeOption(opt.id)}
                          className="p-2 text-text-secondary hover:text-danger hover:bg-danger-light rounded-lg transition-colors"
                        >
                          <Trash2 className="size-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="flex justify-end pt-2">
                <button
                  onClick={() => saveQuestionMutation.mutate()}
                  disabled={saveQuestionMutation.isPending}
                  className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50"
                >
                  {saveQuestionMutation.isPending ? (
                    <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  ) : (
                    <Save className="size-4" />
                  )}
                  Enregistrer
                </button>
              </div>
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center py-16 text-text-secondary">
              <ArrowLeft className="size-10 mb-3 text-gray-300" />
              <p className="text-sm">
                Sélectionnez une question dans la liste pour l'éditer
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
