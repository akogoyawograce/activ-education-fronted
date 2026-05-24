import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, Plus, Filter, Image, Save } from 'lucide-react'
import * as bibliothequeService from '@/api/bibliotheque'
import type { FicheFiliereResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

interface FiliereForm {
  titre: string
  resume: string
  contenu: string
  domaine: string
  duree: string
  niveauRequis: string
  conditionsAdmission: string
  programme: string
  debouchesMetiers: string
  estPublie: boolean
}

const emptyForm: FiliereForm = {
  titre: '',
  resume: '',
  contenu: '',
  domaine: '',
  duree: '',
  niveauRequis: '',
  conditionsAdmission: '',
  programme: '',
  debouchesMetiers: '',
  estPublie: false,
}

export default function FilieresPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [domaine, setDomaine] = useState('')
  const [selected, setSelected] = useState<FicheFiliereResponse | null>(null)
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState<FiliereForm>(emptyForm)

  const { data, isLoading } = useQuery({
    queryKey: ['filieres', page, search, domaine],
    queryFn: () => {
      if (search.trim()) {
        return bibliothequeService.searchFilieres(search, page - 1, 10)
      }
      return bibliothequeService.getAllFilieres(page - 1, 10)
    },
  })

  const dommainesQuery = useQuery({
    queryKey: ['filieres-domaines'],
    queryFn: () => bibliothequeService.getAllFilieres(0, 100),
    select: (d) => {
      const domaines = new Set<string>()
      d.content.forEach((f) => {
        if (f.domaine) domaines.add(f.domaine)
      })
      return Array.from(domaines)
    },
  })

  const createMutation = useMutation({
    mutationFn: (data: FiliereForm) =>
      bibliothequeService.createFiliere({
        titre: data.titre,
        resume: data.resume,
        contenu: data.contenu,
        estPublie: data.estPublie,
        duree: data.duree,
        niveauRequis: data.niveauRequis,
        conditionsAdmission: data.conditionsAdmission,
        programme: data.programme,
        debouchesMetiers: data.debouchesMetiers,
        domaine: data.domaine,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['filieres'] })
      setShowCreate(false)
      setForm(emptyForm)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string
      data: Partial<FiliereForm>
    }) =>
      bibliothequeService.updateFiliere(id, {
        titre: data.titre ?? '',
        resume: data.resume ?? '',
        contenu: data.contenu ?? '',
        estPublie: data.estPublie ?? false,
        duree: data.duree ?? '',
        niveauRequis: data.niveauRequis ?? '',
        conditionsAdmission: data.conditionsAdmission,
        programme: data.programme,
        debouchesMetiers: data.debouchesMetiers,
        domaine: data.domaine,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['filieres'] })
      queryClient.invalidateQueries({ queryKey: ['filiere-detail'] })
    },
  })

  function togglePublish(item: FicheFiliereResponse) {
    updateMutation.mutate({
      id: item.trackingId,
      data: { estPublie: !item.estPublie },
    })
    setSelected((prev) =>
      prev?.trackingId === item.trackingId
        ? { ...prev, estPublie: !prev.estPublie }
        : prev,
    )
  }

  function handleCreate(e: React.FormEvent) {
    e.preventDefault()
    createMutation.mutate(form)
  }

  const columns = [
    { key: 'titre', label: 'Titre' },
    { key: 'domaine', label: 'Domaine' },
    {
      key: 'etablissements',
      label: 'Établissements',
      render: (item: FicheFiliereResponse) => (
        <span className="text-text-secondary">
          {item.etablissements?.length ?? 0}
        </span>
      ),
    },
    {
      key: 'estPublie',
      label: 'Statut',
      render: (item: FicheFiliereResponse) => (
        <StatusBadge status={item.estPublie ? 'PUBLIE' : 'BROUILLON'} />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: FicheFiliereResponse) => (
        <button
          onClick={(e) => {
            e.stopPropagation()
            togglePublish(item)
          }}
          className={`text-xs font-medium px-2.5 py-1 rounded-lg transition-colors ${
            item.estPublie
              ? 'bg-secondary-light text-secondary hover:bg-amber-200'
              : 'bg-success-light text-success hover:bg-emerald-200'
          }`}
        >
          {item.estPublie ? 'Dépublier' : 'Publier'}
        </button>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestion des filières"
        description={`${data?.totalElements ?? 0} filières`}
        actions={
          <button
            onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouvelle filière
          </button>
        }
      />

      <div className="flex items-center gap-4">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher une filière..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value)
              setPage(1)
            }}
            className="w-full pl-10 pr-4 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <select
            value={domaine}
            onChange={(e) => {
              setDomaine(e.target.value)
              setPage(1)
            }}
            className="pl-10 pr-8 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary appearance-none"
          >
            <option value="">Tous les domaines</option>
            {dommainesQuery.data?.map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
        </div>
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
        title={selected?.titre ?? 'Détails'}
        size="lg"
      >
        {selected && (
          <div className="space-y-5">
            <div className="flex items-start gap-4">
              <div className="w-24 h-24 rounded-xl bg-gray-100 flex items-center justify-center shrink-0">
                <Image className="size-8 text-gray-300" />
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-text-main">{selected.titre}</h3>
                <p className="text-sm text-text-secondary mt-1">{selected.resume}</p>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-light text-primary mt-2">
                  {selected.domaine}
                </span>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-text-secondary block">Durée</span>
                <span className="text-text-main font-medium">{selected.duree || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Niveau requis</span>
                <span className="text-text-main font-medium">{selected.niveauRequis || '-'}</span>
              </div>
              <div className="col-span-2">
                <span className="text-text-secondary block">Débouchés</span>
                <span className="text-text-main font-medium">
                  {selected.debouchesMetiers || '-'}
                </span>
              </div>
              <div className="col-span-2">
                <span className="text-text-secondary block">Conditions d'admission</span>
                <span className="text-text-main font-medium">
                  {selected.conditionsAdmission || '-'}
                </span>
              </div>
            </div>
            <div className="flex items-center justify-between pt-3 border-t border-border">
              <span className="text-sm text-text-secondary">
                Statut actuel :{' '}
                <StatusBadge status={selected.estPublie ? 'PUBLIE' : 'BROUILLON'} />
              </span>
              <button
                onClick={() => togglePublish(selected)}
                className={`text-sm font-medium px-4 py-2 rounded-lg transition-colors ${
                  selected.estPublie
                    ? 'bg-secondary-light text-secondary hover:bg-amber-200'
                    : 'bg-success-light text-success hover:bg-emerald-200'
                }`}
              >
                {selected.estPublie ? 'Dépublier' : 'Publier'}
              </button>
            </div>
          </div>
        )}
      </Modal>

      <Modal
        open={showCreate}
        onClose={() => {
          setShowCreate(false)
          setForm(emptyForm)
        }}
        title="Nouvelle filière"
        size="lg"
      >
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Titre</label>
            <input
              required
              value={form.titre}
              onChange={(e) => setForm((f) => ({ ...f, titre: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Résumé</label>
            <textarea
              rows={3}
              value={form.resume}
              onChange={(e) => setForm((f) => ({ ...f, resume: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Domaine</label>
              <input
                value={form.domaine}
                onChange={(e) => setForm((f) => ({ ...f, domaine: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Durée</label>
              <input
                value={form.duree}
                onChange={(e) => setForm((f) => ({ ...f, duree: e.target.value }))}
                placeholder="Ex: 3 ans"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Niveau requis</label>
              <input
                value={form.niveauRequis}
                onChange={(e) => setForm((f) => ({ ...f, niveauRequis: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Débouchés</label>
              <input
                value={form.debouchesMetiers}
                onChange={(e) => setForm((f) => ({ ...f, debouchesMetiers: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={() => {
                setShowCreate(false)
                setForm(emptyForm)
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
              {createMutation.isPending ? (
                <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <Save className="size-4" />
              )}
              Créer
            </button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
