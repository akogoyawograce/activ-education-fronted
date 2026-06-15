import { useState, useEffect } from 'react'
import { Plus, Trash2, Save } from 'lucide-react'
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

interface QuestionFormProps {
  question: QuestionResponse
  onSave: (data: {
    texteQuestion: string
    domaine: string
    difficulte: number
    tags: string
    typeQuestion: string
    niveauCible: string
  }) => void
  onAddOption: (questionId: string) => void
  onUpdateOption: (params: { id: string; texte: string }) => void
  onRemoveOption: (id: string) => void
}

export function QuestionForm({
  question,
  onSave,
  onAddOption,
  onUpdateOption,
  onRemoveOption,
}: QuestionFormProps) {
  const [questionText, setQuestionText] = useState(question.texteQuestion)
  const [domaine, setDomaine] = useState(question.domaine ?? '')
  const [difficulte, setDifficulte] = useState(question.difficulte ?? 1)
  const [tags, setTags] = useState(question.tags ?? '')
  const [typeQuestion, setTypeQuestion] = useState(question.typeQuestion ?? 'RIASEC')
  const [niveauCible, setNiveauCible] = useState(question.niveauCible ?? '')
  const [options, setOptions] = useState<OptionItem[]>([])

  useEffect(() => {
    async function load() {
      try {
        const reps = await quizService.getReponses(question.trackingId)
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
    load()
  }, [question.trackingId])

  function updateOption(id: string, texte: string) {
    setOptions((prev) =>
      prev.map((o) => (o.id === id ? { ...o, texte } : o)),
    )
    onUpdateOption({ id, texte })
  }

  return (
    <div className="bg-card rounded-[12px] border border-border p-5">
      <div className="space-y-5">
        <h2 className="text-sm font-semibold text-text-main">Question</h2>

        <div>
          <label className="block text-sm font-medium text-text-main mb-1">
            Texte de la question
          </label>
          <textarea
            rows={3}
            value={questionText}
            onChange={(e) => setQuestionText(e.target.value)}
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
              onClick={() => onAddOption(question.trackingId)}
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
                    onClick={() => onRemoveOption(opt.id)}
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
            onClick={() =>
              onSave({
                texteQuestion: questionText,
                domaine,
                difficulte,
                tags,
                typeQuestion,
                niveauCible,
              })
            }
            className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors"
          >
            <Save className="size-4" />
            Enregistrer
          </button>
        </div>
      </div>
    </div>
  )
}
