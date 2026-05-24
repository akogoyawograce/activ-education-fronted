import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { format, parseISO } from 'date-fns'
import { fr } from 'date-fns/locale'
import { Video, Phone, MapPin, CheckCircle, XCircle, Eye } from 'lucide-react'
import { useAuthStore } from '@/stores/authStore'
import * as rendezvousService from '@/api/rendezvous'
import PageHeader from '@/components/shared/PageHeader'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import Modal from '@/components/ui/Modal'
import { SkeletonCard } from '@/components/ui/Skeleton'
import type { RendezVousResponse } from '@/types'

const STATUTS = ['TOUS', 'PLANIFIE', 'CONFIRME', 'TERMINE', 'ANNULE'] as const

const typeIcon: Record<string, { icon: typeof Video; label: string }> = {
  VISIO: { icon: Video, label: 'Visio' },
  TELEPHONE: { icon: Phone, label: 'Téléphone' },
  PRESENTIEL: { icon: MapPin, label: 'Présentiel' },
}

function getTypeFromNotes(notes: string): keyof typeof typeIcon {
  if (notes.includes('Visio') || notes.includes('visio')) return 'VISIO'
  if (notes.includes('Téléphone') || notes.includes('telephone')) return 'TELEPHONE'
  return 'PRESENTIEL'
}

export default function RendezVousPage() {
  const trackingId = useAuthStore((s) => s.trackingId)
  const queryClient = useQueryClient()
  const [filtreStatut, setFiltreStatut] = useState<string>('TOUS')
  const [selectedRdv, setSelectedRdv] = useState<RendezVousResponse | null>(null)

  const { data: rendezVous, isLoading } = useQuery({
    queryKey: ['rendezvous', trackingId],
    queryFn: () => rendezvousService.getByConseiller(trackingId!),
    enabled: !!trackingId,
  })

  const updateStatutMutation = useMutation({
    mutationFn: ({ id, statut }: { id: string; statut: string }) =>
      statut === 'TERMINE'
        ? rendezvousService.terminer(id)
        : rendezvousService.annuler(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rendezvous', trackingId] })
      setSelectedRdv(null)
    },
  })

  const filtered = (rendezVous ?? []).filter(
    (r) => filtreStatut === 'TOUS' || r.statut === filtreStatut,
  )

  const columns = [
    {
      key: 'date',
      label: 'Date / Heure',
      render: (r: RendezVousResponse) => (
        <span className="text-sm">
          {format(parseISO(r.dateHeurePrevue), 'dd MMM yyyy HH:mm', { locale: fr })}
        </span>
      ),
    },
    {
      key: 'eleve',
      label: 'Élève',
      render: (r: RendezVousResponse) => (
        <span className="text-sm font-medium">{r.eleveTrackingId}</span>
      ),
    },
    {
      key: 'type',
      label: 'Type',
      render: (r: RendezVousResponse) => {
        const type = getTypeFromNotes(r.notes || '')
        const config = typeIcon[type]
        const Icon = config?.icon ?? MapPin
        return (
          <div className="flex items-center gap-1.5 text-sm text-text-secondary">
            <Icon className="size-4" />
            <span>{config?.label ?? 'Présentiel'}</span>
          </div>
        )
      },
    },
    {
      key: 'statut',
      label: 'Statut',
      render: (r: RendezVousResponse) => <StatusBadge status={r.statut} />,
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (r: RendezVousResponse) => (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => {
              e.stopPropagation()
              setSelectedRdv(r)
            }}
            className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors text-text-secondary"
            title="Voir détails"
          >
            <Eye className="size-4" />
          </button>
          {r.statut === 'PLANIFIE' || r.statut === 'CONFIRME' ? (
            <>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  updateStatutMutation.mutate({ id: r.trackingId, statut: 'TERMINE' })
                }}
                className="p-1.5 rounded-lg hover:bg-success-light transition-colors text-success"
                title="Marquer terminé"
              >
                <CheckCircle className="size-4" />
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  updateStatutMutation.mutate({ id: r.trackingId, statut: 'ANNULE' })
                }}
                className="p-1.5 rounded-lg hover:bg-danger-light transition-colors text-danger"
                title="Annuler"
              >
                <XCircle className="size-4" />
              </button>
            </>
          ) : null}
        </div>
      ),
    },
  ]

  if (isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader title="Rendez-vous" description="Gérez vos rendez-vous" />
        <div className="grid grid-cols-1 gap-4">
          {Array.from({ length: 3 }).map((_, i) => <SkeletonCard key={i} />)}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Rendez-vous"
        description="Gérez vos rendez-vous avec les élèves"
      />

      <div className="flex items-center gap-2 flex-wrap">
        {STATUTS.map((s) => (
          <button
            key={s}
            onClick={() => setFiltreStatut(s)}
            className={`px-3 py-1.5 rounded-full text-xs font-medium transition-colors ${
              filtreStatut === s
                ? 'bg-primary text-white'
                : 'bg-gray-100 text-text-secondary hover:bg-gray-200'
            }`}
          >
            {s === 'TOUS' ? 'Tous' : s.charAt(0) + s.slice(1).toLowerCase()}
          </button>
        ))}
      </div>

      <DataTable
        columns={columns}
        data={filtered}
        onRowClick={(r) => setSelectedRdv(r)}
      />

      <Modal
        open={!!selectedRdv}
        onClose={() => setSelectedRdv(null)}
        title="Détails du rendez-vous"
        size="md"
      >
        {selectedRdv && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Date & Heure</p>
                <p className="text-sm text-text-main mt-1">
                  {format(parseISO(selectedRdv.dateHeurePrevue), 'dd MMMM yyyy HH:mm', { locale: fr })}
                </p>
              </div>
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Statut</p>
                <div className="mt-1"><StatusBadge status={selectedRdv.statut} /></div>
              </div>
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Élève</p>
                <p className="text-sm text-text-main mt-1">{selectedRdv.eleveTrackingId}</p>
              </div>
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Type</p>
                <p className="text-sm text-text-main mt-1">
                  {typeIcon[getTypeFromNotes(selectedRdv.notes || '')]?.label ?? 'Présentiel'}
                </p>
              </div>
            </div>
            {selectedRdv.notes && (
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Notes</p>
                <p className="text-sm text-text-main mt-1">{selectedRdv.notes}</p>
              </div>
            )}
            {selectedRdv.lienVisio && (
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Lien Visio</p>
                <a
                  href={selectedRdv.lienVisio}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-primary hover:underline mt-1 block"
                >
                  {selectedRdv.lienVisio}
                </a>
              </div>
            )}
            <div className="flex gap-2 pt-2">
              {(selectedRdv.statut === 'PLANIFIE' || selectedRdv.statut === 'CONFIRME') && (
                <>
                  <button
                    onClick={() => updateStatutMutation.mutate({ id: selectedRdv.trackingId, statut: 'TERMINE' })}
                    className="px-4 py-2 bg-success text-white rounded-lg text-sm font-medium hover:bg-success/90 transition-colors"
                  >
                    Marquer terminé
                  </button>
                  <button
                    onClick={() => updateStatutMutation.mutate({ id: selectedRdv.trackingId, statut: 'ANNULE' })}
                    className="px-4 py-2 bg-danger text-white rounded-lg text-sm font-medium hover:bg-danger/90 transition-colors"
                  >
                    Annuler
                  </button>
                </>
              )}
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
