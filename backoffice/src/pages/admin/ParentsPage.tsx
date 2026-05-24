import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Search, UserPlus } from 'lucide-react'
import * as parentService from '@/api/parents'
import * as eleveService from '@/api/eleves'
import type { ParentResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import UserAvatar from '@/components/ui/UserAvatar'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

export default function ParentsPage() {
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState<ParentResponse | null>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['parents', page, search],
    queryFn: () => parentService.getAll(page - 1, 10),
  })

  const { data: childrenMap } = useQuery({
    queryKey: ['parents-children', selected?.enfantsTrackingIds],
    queryFn: async () => {
      if (!selected?.enfantsTrackingIds?.length) return {}
      const results: Record<string, string> = {}
      for (const id of selected.enfantsTrackingIds) {
        try {
          const eleve = await eleveService.getById(id)
          results[id] = `${eleve.prenom} ${eleve.nom}`
        } catch {
          results[id] = 'Inconnu'
        }
      }
      return results
    },
    enabled: !!selected,
  })

  const columns = [
    {
      key: 'avatar',
      label: '',
      render: (item: ParentResponse) => (
        <UserAvatar name={`${item.prenom} ${item.nom}`} size="sm" />
      ),
    },
    { key: 'nom', label: 'Nom' },
    { key: 'prenom', label: 'Prénom' },
    { key: 'email', label: 'Email' },
    { key: 'telephone', label: 'Téléphone' },
    {
      key: 'enfants',
      label: 'Enfants',
      render: (item: ParentResponse) => (
        <span className="font-medium text-primary">
          {item.enfantsTrackingIds?.length ?? 0}
        </span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestion des parents"
        description={`${data?.totalElements ?? 0} parents inscrits`}
        actions={
          <button className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors">
            <UserPlus className="size-4" />
            Nouveau parent
          </button>
        }
      />

      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
        <input
          type="text"
          placeholder="Rechercher par nom ou email..."
          value={search}
          onChange={(e) => {
            setSearch(e.target.value)
            setPage(1)
          }}
          className="w-full pl-10 pr-4 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
      </div>

      <DataTable
        columns={columns}
        data={data?.content ?? []}
        loading={isLoading}
        onRowClick={(item) => setSelected(item)}
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
        open={!!selected}
        onClose={() => setSelected(null)}
        title="Détails du parent"
        size="lg"
      >
        {selected && (
          <div className="space-y-5">
            <div className="flex items-center gap-4 pb-4 border-b border-border">
              <UserAvatar name={`${selected.prenom} ${selected.nom}`} size="lg" />
              <div>
                <h3 className="text-lg font-semibold text-text-main">
                  {selected.prenom} {selected.nom}
                </h3>
                <p className="text-sm text-text-secondary">{selected.email}</p>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-text-secondary block">Nom</span>
                <span className="text-text-main font-medium">{selected.nom}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Prénom</span>
                <span className="text-text-main font-medium">{selected.prenom}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Email</span>
                <span className="text-text-main font-medium">{selected.email}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Téléphone</span>
                <span className="text-text-main font-medium">{selected.telephone || '-'}</span>
              </div>
            </div>
            <div className="pt-2">
              <h4 className="text-sm font-semibold text-text-main mb-3">
                Enfants liés ({selected.enfantsTrackingIds?.length ?? 0})
              </h4>
              {selected.enfantsTrackingIds?.length ? (
                <div className="space-y-2">
                  {selected.enfantsTrackingIds.map((id) => (
                    <div
                      key={id}
                      className="flex items-center gap-3 px-3 py-2 bg-gray-50 rounded-lg text-sm"
                    >
                      <UserAvatar name={childrenMap?.[id] ?? '?'} size="sm" />
                      <span className="text-text-main">
                        {childrenMap?.[id] ?? 'Chargement...'}
                      </span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-text-secondary">Aucun enfant lié</p>
              )}
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
