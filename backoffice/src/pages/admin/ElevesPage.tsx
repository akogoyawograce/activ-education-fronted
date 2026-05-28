import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Search, UserPlus } from 'lucide-react'
import * as eleveService from '@/api/eleves'
import type { EleveResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import UserAvatar from '@/components/ui/UserAvatar'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

export default function ElevesPage() {
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState<EleveResponse | null>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['eleves', page, search],
    queryFn: () => {
      if (search.trim()) {
        return eleveService.getAll(page - 1, 10)
      }
      return eleveService.getAll(page - 1, 10)
    },
  })

  const columns = [
    {
      key: 'avatar',
      label: '',
      render: (item: EleveResponse) => (
        <UserAvatar name={`${item.prenom} ${item.nom}`} size="sm" />
      ),
    },
    { key: 'nom', label: 'Nom' },
    { key: 'prenom', label: 'Prénom' },
    { key: 'email', label: 'Email' },
    { key: 'telephone', label: 'Téléphone' },
    { key: 'typeApprenant', label: 'Type' },
    { key: 'niveauEtude', label: 'Niveau' },
    { key: 'etablissementActuel', label: 'Établissement' },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestion des étudiants"
        description={`${data?.totalElements ?? 0} élèves inscrits`}
        actions={
          <button className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors">
            <UserPlus className="size-4" />
            Nouvel élève
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
        title="Détails de l'élève"
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
              <div>
                <span className="text-text-secondary block">Niveau d'étude</span>
                <span className="text-text-main font-medium">{selected.niveauEtude || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Type d'apprenant</span>
                <span className="text-text-main font-medium">{selected.typeApprenant || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Établissement</span>
                <span className="text-text-main font-medium">
                  {selected.etablissementActuel || '-'}
                </span>
              </div>
              <div>
                <span className="text-text-secondary block">Filière</span>
                <span className="text-text-main font-medium">{selected.filiere || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Métier souhaité</span>
                <span className="text-text-main font-medium">{selected.metierSouhaite || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Matières préférées</span>
                <span className="text-text-main font-medium">{selected.matieresPreferees?.join(', ') || '-'}</span>
              </div>
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
