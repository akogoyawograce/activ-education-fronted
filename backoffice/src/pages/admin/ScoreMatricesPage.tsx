import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Plus, Pencil, Trash2, Save } from 'lucide-react'
import * as scoreMatriceService from '@/api/scoreMatrices'
import type { ScoreMatriceResponse } from '@/types'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

export default function ScoreMatricesPage() {
  const queryClient = useQueryClient()
  const [editTarget, setEditTarget] = useState<ScoreMatriceResponse | null>(null)
  const [editForm, setEditForm] = useState({ titreMatrice: '', scoreGoutsPersonnel: 0, scoreAcademique: 0, scoreMarcheTravail: 0 })
  const [createOpen, setCreateOpen] = useState(false)
  const [createForm, setCreateForm] = useState({ titreMatrice: '', scoreGoutsPersonnel: 0, scoreAcademique: 0, scoreMarcheTravail: 0 })

  const { data, isLoading } = useQuery({
    queryKey: ['score-matrices'],
    queryFn: () => scoreMatriceService.getAll(),
  })

  const createMutation = useMutation({
    mutationFn: () =>
      scoreMatriceService.create(createForm),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['score-matrices'] })
      setCreateOpen(false)
      setCreateForm({ titreMatrice: '', scoreGoutsPersonnel: 0, scoreAcademique: 0, scoreMarcheTravail: 0 })
    },
  })

  const updateMutation = useMutation({
    mutationFn: () =>
      scoreMatriceService.update(editTarget!.trackingId, editForm),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['score-matrices'] })
      setEditTarget(null)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => scoreMatriceService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['score-matrices'] })
    },
  })

  function openEdit(item: ScoreMatriceResponse) {
    setEditTarget(item)
    setEditForm({
      titreMatrice: item.titreMatrice,
      scoreGoutsPersonnel: item.scoreGoutsPersonnel,
      scoreAcademique: item.scoreAcademique,
      scoreMarcheTravail: item.scoreMarcheTravail,
    })
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Matrices de scores"
        description={`${data?.length ?? 0} matrices configurées`}
        actions={
          <button
            onClick={() => setCreateOpen(true)}
            className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouvelle matrice
          </button>
        }
      />

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
          <p className="text-text-secondary text-sm">Aucune matrice de score configurée</p>
        </div>
      ) : (
        <div className="bg-card rounded-[12px] border border-border overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-gray-50/50">
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Titre</th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Goûts personnels</th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Académique</th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Marché du travail</th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Total estimé</th>
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {data.map((item) => (
                <tr key={item.trackingId} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3 font-medium text-text-main">{item.titreMatrice}</td>
                  <td className="px-4 py-3 text-text-secondary">{item.scoreGoutsPersonnel}</td>
                  <td className="px-4 py-3 text-text-secondary">{item.scoreAcademique}</td>
                  <td className="px-4 py-3 text-text-secondary">{item.scoreMarcheTravail}</td>
                  <td className="px-4 py-3"><span className="font-semibold text-primary">{item.scoreTotalEstime}</span></td>
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
                          if (window.confirm(`Supprimer la matrice "${item.titreMatrice}" ?`)) {
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

      <Modal open={createOpen} onClose={() => setCreateOpen(false)} title="Nouvelle matrice de score" size="sm">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Titre de la matrice</label>
            <input type="text" value={createForm.titreMatrice}
              onChange={(e) => setCreateForm(p => ({ ...p, titreMatrice: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
          </div>
          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Goûts personnels</label>
              <input type="number" min={0} step={0.5} value={createForm.scoreGoutsPersonnel}
                onChange={(e) => setCreateForm(p => ({ ...p, scoreGoutsPersonnel: parseFloat(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Académique</label>
              <input type="number" min={0} step={0.5} value={createForm.scoreAcademique}
                onChange={(e) => setCreateForm(p => ({ ...p, scoreAcademique: parseFloat(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Marché du travail</label>
              <input type="number" min={0} step={0.5} value={createForm.scoreMarcheTravail}
                onChange={(e) => setCreateForm(p => ({ ...p, scoreMarcheTravail: parseFloat(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button onClick={() => setCreateOpen(false)}
              className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors">
              Annuler
            </button>
            <button onClick={() => createMutation.mutate()} disabled={createMutation.isPending || !createForm.titreMatrice.trim()}
              className="px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2">
              {createMutation.isPending ? <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <Save className="size-4" />}
              Créer
            </button>
          </div>
        </div>
      </Modal>

      <Modal open={!!editTarget} onClose={() => setEditTarget(null)} title="Modifier la matrice" size="sm">
        {editTarget && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Titre de la matrice</label>
              <input type="text" value={editForm.titreMatrice}
                onChange={(e) => setEditForm(p => ({ ...p, titreMatrice: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
            </div>
            <div className="grid grid-cols-3 gap-3">
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Goûts personnels</label>
                <input type="number" min={0} step={0.5} value={editForm.scoreGoutsPersonnel}
                  onChange={(e) => setEditForm(p => ({ ...p, scoreGoutsPersonnel: parseFloat(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Académique</label>
                <input type="number" min={0} step={0.5} value={editForm.scoreAcademique}
                  onChange={(e) => setEditForm(p => ({ ...p, scoreAcademique: parseFloat(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Marché du travail</label>
                <input type="number" min={0} step={0.5} value={editForm.scoreMarcheTravail}
                  onChange={(e) => setEditForm(p => ({ ...p, scoreMarcheTravail: parseFloat(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary" />
              </div>
            </div>
            <div className="flex justify-end gap-3 pt-2">
              <button onClick={() => setEditTarget(null)}
                className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors">
                Annuler
              </button>
              <button onClick={() => updateMutation.mutate()} disabled={updateMutation.isPending}
                className="px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2">
                {updateMutation.isPending ? <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <Save className="size-4" />}
                Enregistrer
              </button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
