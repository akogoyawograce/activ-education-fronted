import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Pencil, Save, Plus, Trash2, Search } from 'lucide-react'
import * as seuilService from '@/api/seuils'
import type { SeuilAdmissionResponse } from '@/types'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

export default function SeuilsPage() {
  const queryClient = useQueryClient()
  const [editTarget, setEditTarget] = useState<SeuilAdmissionResponse | null>(null)
  const [editValue, setEditValue] = useState(0)
  const [createOpen, setCreateOpen] = useState(false)
  const [createForm, setCreateForm] = useState({
    filiereTrackingId: '',
    matiereRequise: '',
    noteMinimum: 10,
  })
  const [filterFiliereId, setFilterFiliereId] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['seuils', filterFiliereId],
    queryFn: () =>
      filterFiliereId.trim()
        ? seuilService.getByFiliere(filterFiliereId.trim())
        : seuilService.getAll(),
  })

  const updateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string
      data: { noteMinimum: number }
    }) =>
      seuilService.update(id, {
        matiereRequise: editTarget?.matiereRequise ?? '',
        noteMinimum: data.noteMinimum,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['seuils'] })
      setEditTarget(null)
    },
  })

  const createMutation = useMutation({
    mutationFn: () =>
      seuilService.create({
        filiereTrackingId: createForm.filiereTrackingId,
        matiereRequise: createForm.matiereRequise,
        noteMinimum: createForm.noteMinimum,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['seuils'] })
      setCreateOpen(false)
      setCreateForm({ filiereTrackingId: '', matiereRequise: '', noteMinimum: 10 })
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => seuilService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['seuils'] })
    },
  })

  function openEdit(item: SeuilAdmissionResponse) {
    setEditTarget(item)
    setEditValue(item.noteMinimum)
  }

  function handleSave() {
    if (editTarget) {
      updateMutation.mutate({
        id: editTarget.trackingId,
        data: { noteMinimum: editValue },
      })
    }
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Seuils d'admission"
        description={`${data?.length ?? 0} seuils configurés`}
        actions={
          <button
            onClick={() => setCreateOpen(true)}
            className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouveau seuil
          </button>
        }
      />

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
        <input
          type="text"
          value={filterFiliereId}
          onChange={(e) => setFilterFiliereId(e.target.value)}
          placeholder="Filtrer par trackingId de filière…"
          className="w-full max-w-sm pl-9 pr-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
      </div>

      {isLoading ? (
        <div className="bg-card rounded-[12px] border border-border p-8">
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="h-10 bg-gray-200 rounded animate-pulse" />
            ))}
          </div>
        </div>
      ) : !data || data.length === 0 ? (
        <div className="bg-card rounded-[12px] border border-border p-12 text-center">
          <p className="text-text-secondary text-sm">Aucun seuil d'admission configuré</p>
        </div>
      ) : (
        <div className="bg-card rounded-[12px] border border-border overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-gray-50/50">
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                  Filière
                </th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                  Matière
                </th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                  Seuil minimum
                </th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {data.map((item) => (
                <tr key={item.trackingId} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3 font-medium text-text-main">
                    {item.filiereTitre || item.filiereTrackingId || '-'}
                  </td>
                  <td className="px-4 py-3 text-text-secondary">
                    {item.matiereRequise || '-'}
                  </td>
                  <td className="px-4 py-3">
                    <span className="font-semibold text-primary">{item.noteMinimum}/20</span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1">
                      <button
                        onClick={() => openEdit(item)}
                        className="flex items-center gap-1.5 text-xs font-medium text-primary hover:bg-primary-light px-2.5 py-1.5 rounded-lg transition-colors"
                      >
                        <Pencil className="size-3.5" />
                        Modifier
                      </button>
                      <button
                        onClick={() => {
                          if (window.confirm(`Supprimer ce seuil pour ${item.filiereTitre || item.filiereTrackingId} ?`)) {
                            deleteMutation.mutate(item.trackingId)
                          }
                        }}
                        disabled={deleteMutation.isPending}
                        className="flex items-center gap-1.5 text-xs font-medium text-red-600 hover:bg-red-50 px-2.5 py-1.5 rounded-lg transition-colors disabled:opacity-50"
                      >
                        <Trash2 className="size-3.5" />
                        Supprimer
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <Modal
        open={!!editTarget}
        onClose={() => setEditTarget(null)}
        title="Modifier le seuil"
        size="sm"
      >
        {editTarget && (
          <div className="space-y-4">
            <div className="text-sm">
              <p className="text-text-secondary">
                Filière :{' '}
                <span className="font-medium text-text-main">
                  {editTarget.filiereTitre || editTarget.filiereTrackingId}
                </span>
              </p>
              {editTarget.matiereRequise && (
                <p className="text-text-secondary mt-1">
                  Matière :{' '}
                  <span className="font-medium text-text-main">
                    {editTarget.matiereRequise}
                  </span>
                </p>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">
                Note minimum (sur 20)
              </label>
              <input
                type="number"
                min={0}
                max={20}
                step={0.5}
                value={editValue}
                onChange={(e) => setEditValue(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div className="flex justify-end gap-3 pt-2">
              <button
                onClick={() => setEditTarget(null)}
                className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
              >
                Annuler
              </button>
              <button
                onClick={handleSave}
                disabled={updateMutation.isPending}
                className="px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                {updateMutation.isPending ? (
                  <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                ) : (
                  <Save className="size-4" />
                )}
                Enregistrer
              </button>
            </div>
          </div>
        )}
      </Modal>

      <Modal
        open={createOpen}
        onClose={() => setCreateOpen(false)}
        title="Nouveau seuil d'admission"
        size="sm"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">
              TrackingId de la filière
            </label>
            <input
              type="text"
              value={createForm.filiereTrackingId}
              onChange={(e) =>
                setCreateForm((prev) => ({ ...prev, filiereTrackingId: e.target.value }))
              }
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">
              Matière requise
            </label>
            <input
              type="text"
              value={createForm.matiereRequise}
              onChange={(e) =>
                setCreateForm((prev) => ({ ...prev, matiereRequise: e.target.value }))
              }
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">
              Note minimum (sur 20)
            </label>
            <input
              type="number"
              min={0}
              max={20}
              step={0.5}
              value={createForm.noteMinimum}
              onChange={(e) =>
                setCreateForm((prev) => ({
                  ...prev,
                  noteMinimum: parseFloat(e.target.value) || 0,
                }))
              }
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button
              onClick={() => setCreateOpen(false)}
              className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              onClick={() => createMutation.mutate()}
              disabled={
                createMutation.isPending ||
                !createForm.filiereTrackingId.trim() ||
                !createForm.matiereRequise.trim()
              }
              className="px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2"
            >
              {createMutation.isPending ? (
                <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <Save className="size-4" />
              )}
              Créer
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
