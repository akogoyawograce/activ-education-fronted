import { useState, useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Search, Mail, Phone, GraduationCap, Users } from 'lucide-react'
import * as eleveService from '@/api/eleves'
import * as parentService from '@/api/parents'
import PageHeader from '@/components/shared/PageHeader'
import UserAvatar from '@/components/ui/UserAvatar'
import Modal from '@/components/ui/Modal'
import { SkeletonCard } from '@/components/ui/Skeleton'
import type { EleveResponse, ParentResponse } from '@/types'

type Tab = 'ELEVES' | 'PARENTS'

export default function UtilisateursPage() {
  const [tab, setTab] = useState<Tab>('ELEVES')
  const [search, setSearch] = useState('')
  const [selectedEleve, setSelectedEleve] = useState<EleveResponse | null>(null)
  const [selectedParent, setSelectedParent] = useState<ParentResponse | null>(null)

  const { data: elevesPage, isLoading: loadingEleves } = useQuery({
    queryKey: ['eleves'],
    queryFn: () => eleveService.getAll(0, 100),
  })

  const { data: parentsPage, isLoading: loadingParents } = useQuery({
    queryKey: ['parents'],
    queryFn: () => parentService.getAll(0, 100),
  })

  const filteredEleves = useMemo(() => {
    if (!elevesPage?.content) return []
    const items = elevesPage.content
    if (!search) return items
    const q = search.toLowerCase()
    return items.filter(
      (e) =>
        e.nom.toLowerCase().includes(q) ||
        e.prenom.toLowerCase().includes(q) ||
        e.email.toLowerCase().includes(q),
    )
  }, [elevesPage, search])

  const filteredParents = useMemo(() => {
    if (!parentsPage?.content) return []
    const items = parentsPage.content
    if (!search) return items
    const q = search.toLowerCase()
    return items.filter(
      (p) =>
        p.nom.toLowerCase().includes(q) ||
        p.prenom.toLowerCase().includes(q) ||
        p.email.toLowerCase().includes(q),
    )
  }, [parentsPage, search])

  const isLoading = tab === 'ELEVES' ? loadingEleves : loadingParents

  return (
    <div className="space-y-6">
      <PageHeader
        title="Utilisateurs"
        description="Annuaire des élèves et parents"
      />

      <div className="flex items-center gap-2">
        <button
          onClick={() => { setTab('ELEVES'); setSearch('') }}
          className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center gap-2 ${
            tab === 'ELEVES' ? 'bg-primary text-white' : 'bg-gray-100 text-text-secondary hover:bg-gray-200'
          }`}
        >
          <GraduationCap className="size-4" />
          Élèves
        </button>
        <button
          onClick={() => { setTab('PARENTS'); setSearch('') }}
          className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center gap-2 ${
            tab === 'PARENTS' ? 'bg-primary text-white' : 'bg-gray-100 text-text-secondary hover:bg-gray-200'
          }`}
        >
          <Users className="size-4" />
          Parents
        </button>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
        <input
          type="text"
          placeholder="Rechercher par nom, prénom ou email..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-9 pr-4 py-2 bg-card border border-border rounded-[12px] text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
        />
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => <SkeletonCard key={i} />)}
        </div>
      ) : tab === 'ELEVES' && filteredEleves.length === 0 ? (
        <div className="bg-card rounded-[12px] border border-border p-12 text-center">
          <GraduationCap className="size-10 text-gray-300 mx-auto mb-2" />
          <p className="text-text-secondary">Aucun élève trouvé</p>
        </div>
      ) : tab === 'PARENTS' && filteredParents.length === 0 ? (
        <div className="bg-card rounded-[12px] border border-border p-12 text-center">
          <Users className="size-10 text-gray-300 mx-auto mb-2" />
          <p className="text-text-secondary">Aucun parent trouvé</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {tab === 'ELEVES'
            ? filteredEleves.map((eleve) => (
                <button
                  key={eleve.trackingId}
                  onClick={() => setSelectedEleve(eleve)}
                  className="bg-card rounded-[12px] border border-border p-4 text-left hover:shadow-md transition-shadow"
                >
                  <div className="flex items-center gap-3">
                    <UserAvatar name={`${eleve.prenom} ${eleve.nom}`} size="md" />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-text-main truncate">
                        {eleve.prenom} {eleve.nom}
                      </p>
                      <div className="flex items-center gap-1 text-xs text-text-secondary mt-0.5">
                        <Mail className="size-3" />
                        <span className="truncate">{eleve.email}</span>
                      </div>
                    </div>
                  </div>
                  {eleve.telephone && (
                    <div className="flex items-center gap-1 text-xs text-text-secondary mt-2 ml-[52px]">
                      <Phone className="size-3" />
                      <span>{eleve.telephone}</span>
                    </div>
                  )}
                  {eleve.niveauEtude && (
                    <div className="flex items-center gap-1 text-xs text-text-secondary mt-1 ml-[52px]">
                      <GraduationCap className="size-3" />
                      <span>{eleve.niveauEtude}</span>
                    </div>
                  )}
                </button>
              ))
            : filteredParents.map((parent) => (
                <button
                  key={parent.trackingId}
                  onClick={() => setSelectedParent(parent)}
                  className="bg-card rounded-[12px] border border-border p-4 text-left hover:shadow-md transition-shadow"
                >
                  <div className="flex items-center gap-3">
                    <UserAvatar name={`${parent.prenom} ${parent.nom}`} size="md" />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-text-main truncate">
                        {parent.prenom} {parent.nom}
                      </p>
                      <div className="flex items-center gap-1 text-xs text-text-secondary mt-0.5">
                        <Mail className="size-3" />
                        <span className="truncate">{parent.email}</span>
                      </div>
                    </div>
                  </div>
                  {parent.telephone && (
                    <div className="flex items-center gap-1 text-xs text-text-secondary mt-2 ml-[52px]">
                      <Phone className="size-3" />
                      <span>{parent.telephone}</span>
                    </div>
                  )}
                  {parent.enfantsTrackingIds.length > 0 && (
                    <div className="flex items-center gap-1 text-xs text-text-secondary mt-1 ml-[52px]">
                      <Users className="size-3" />
                      <span>{parent.enfantsTrackingIds.length} enfant(s)</span>
                    </div>
                  )}
                </button>
              ))}
        </div>
      )}

      <Modal
        open={!!selectedEleve}
        onClose={() => setSelectedEleve(null)}
        title="Détails de l'élève"
      >
        {selectedEleve && (
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <UserAvatar name={`${selectedEleve.prenom} ${selectedEleve.nom}`} size="lg" />
              <div>
                <p className="text-lg font-semibold text-text-main">
                  {selectedEleve.prenom} {selectedEleve.nom}
                </p>
                <span className="text-xs text-text-secondary">{selectedEleve.trackingId}</span>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Email</p>
                <p className="text-sm text-text-main mt-1">{selectedEleve.email}</p>
              </div>
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Téléphone</p>
                <p className="text-sm text-text-main mt-1">{selectedEleve.telephone || '-'}</p>
              </div>
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Niveau d'étude</p>
                <p className="text-sm text-text-main mt-1">{selectedEleve.niveauEtude || '-'}</p>
              </div>
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Type d'apprenant</p>
                <p className="text-sm text-text-main mt-1">{selectedEleve.typeApprenant}</p>
              </div>
              {selectedEleve.etablissementActuel && (
                <div className="col-span-2">
                  <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Établissement</p>
                  <p className="text-sm text-text-main mt-1">{selectedEleve.etablissementActuel}</p>
                </div>
              )}
              {selectedEleve.filiere && (
                <div className="col-span-2">
                  <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Filière</p>
                  <p className="text-sm text-text-main mt-1">{selectedEleve.filiere}</p>
                </div>
              )}
            </div>
          </div>
        )}
      </Modal>

      <Modal
        open={!!selectedParent}
        onClose={() => setSelectedParent(null)}
        title="Détails du parent"
      >
        {selectedParent && (
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <UserAvatar name={`${selectedParent.prenom} ${selectedParent.nom}`} size="lg" />
              <div>
                <p className="text-lg font-semibold text-text-main">
                  {selectedParent.prenom} {selectedParent.nom}
                </p>
                <span className="text-xs text-text-secondary">{selectedParent.trackingId}</span>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Email</p>
                <p className="text-sm text-text-main mt-1">{selectedParent.email}</p>
              </div>
              <div>
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">Téléphone</p>
                <p className="text-sm text-text-main mt-1">{selectedParent.telephone || '-'}</p>
              </div>
              <div className="col-span-2">
                <p className="text-xs text-text-secondary uppercase tracking-wider font-semibold">
                  Enfant(s) lié(s)
                </p>
                {selectedParent.enfantsTrackingIds.length > 0 ? (
                  <ul className="mt-1 space-y-1">
                    {selectedParent.enfantsTrackingIds.map((id) => (
                      <li key={id} className="text-sm text-text-main">
                        {id}
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p className="text-sm text-text-secondary mt-1">Aucun enfant lié</p>
                )}
              </div>
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
