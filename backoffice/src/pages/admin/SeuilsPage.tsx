import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Pencil, Save } from 'lucide-react'
import * as seuilService from '@/api/seuils'
import type { SeuilAdmissionResponse } from '@/types'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

export default function SeuilsPage() {
  const queryClient = useQueryClient()
  const [editTarget, setEditTarget] = useState<SeuilAdmissionResponse | null>(null)
  const [editValue, setEditValue] = useState(0)

  const { data, isLoading } = useQuery({
    queryKey: ['seuils'],
    queryFn: () => seuilService.getAll(),
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
                    <button
                      onClick={() => openEdit(item)}
                      className="flex items-center gap-1.5 text-xs font-medium text-primary hover:bg-primary-light px-2.5 py-1.5 rounded-lg transition-colors"
                    >
                      <Pencil className="size-3.5" />
                      Modifier
                    </button>
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
    </div>
  )
}
