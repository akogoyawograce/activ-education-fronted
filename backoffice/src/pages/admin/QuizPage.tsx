import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Plus, Trash2, AlertTriangle } from 'lucide-react'
import * as quizService from '@/api/quiz'
import type { QuizResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

export default function QuizPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [showCreate, setShowCreate] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState<QuizResponse | null>(null)
  const [newTitre, setNewTitre] = useState('')
  const [newDescription, setNewDescription] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['quiz', page],
    queryFn: () => quizService.getAll(page - 1, 10),
  })

  const createMutation = useMutation({
    mutationFn: () => quizService.create({ titre: newTitre, description: newDescription }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['quiz'] })
      setShowCreate(false)
      setNewTitre('')
      setNewDescription('')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => quizService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['quiz'] })
      setDeleteTarget(null)
    },
  })

  function handleCreate(e: React.FormEvent) {
    e.preventDefault()
    createMutation.mutate()
  }

  const columns = [
    { key: 'titre', label: 'Titre' },
    {
      key: 'description',
      label: 'Description',
      render: (item: QuizResponse) => (
        <span className="text-text-secondary line-clamp-1">{item.description || '-'}</span>
      ),
    },
    {
      key: 'nombreQuestions',
      label: 'Questions',
      render: (item: QuizResponse) => (
        <span className="font-medium text-primary">{item.nombreQuestions ?? 0}</span>
      ),
    },
    {
      key: 'estActif',
      label: 'Statut',
      render: (item: QuizResponse) => (
        <StatusBadge status={item.estActif ? 'VALIDE' : 'BROUILLON'} />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: QuizResponse) => (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => {
              e.stopPropagation()
              navigate(`/admin/quiz/${item.trackingId}/edit`)
            }}
            className="text-xs font-medium text-primary hover:bg-primary-light px-2.5 py-1 rounded-lg transition-colors"
          >
            Éditer
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation()
              setDeleteTarget(item)
            }}
            className="text-xs font-medium text-danger hover:bg-danger-light px-2.5 py-1 rounded-lg transition-colors"
          >
            <Trash2 className="size-3.5" />
          </button>
        </div>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestion des quiz"
        description={`${data?.totalElements ?? 0} quiz`}
        actions={
          <button
            onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouveau quiz
          </button>
        }
      />

      <DataTable
        columns={columns}
        data={data?.content ?? []}
        loading={isLoading}
        onRowClick={(item) => navigate(`/admin/quiz/${item.trackingId}/edit`)}
        pagination={
          data
            ? {
                page,
                totalPages: data.totalPages,
                onPageChange: setPage,
              }
            : undefined
        }
      />

      <Modal
        open={showCreate}
        onClose={() => {
          setShowCreate(false)
          setNewTitre('')
          setNewDescription('')
        }}
        title="Nouveau quiz"
      >
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Titre</label>
            <input
              required
              value={newTitre}
              onChange={(e) => setNewTitre(e.target.value)}
              placeholder="Ex: Quiz d'orientation"
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Description</label>
            <textarea
              rows={3}
              value={newDescription}
              onChange={(e) => setNewDescription(e.target.value)}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={() => {
                setShowCreate(false)
                setNewTitre('')
                setNewDescription('')
              }}
              className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending}
              className="px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2"
            >
              {createMutation.isPending && (
                <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              )}
              Créer
            </button>
          </div>
        </form>
      </Modal>

      <Modal
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Confirmer la suppression"
        size="sm"
      >
        <div className="space-y-4">
          <div className="flex items-center gap-3 text-amber-600 bg-amber-50 px-4 py-3 rounded-lg">
            <AlertTriangle className="size-5 shrink-0" />
            <p className="text-sm">
              Supprimer <strong>{deleteTarget?.titre}</strong> ? Cette action est irréversible.
            </p>
          </div>
          <div className="flex justify-end gap-3">
            <button
              onClick={() => setDeleteTarget(null)}
              className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              onClick={() => deleteTarget && deleteMutation.mutate(deleteTarget.trackingId)}
              disabled={deleteMutation.isPending}
              className="px-4 py-2 text-sm font-medium text-white bg-danger hover:bg-red-600 rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2"
            >
              {deleteMutation.isPending && (
                <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              )}
              Supprimer
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
