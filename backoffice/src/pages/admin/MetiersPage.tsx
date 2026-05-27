import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, Plus, Filter, Save, Pencil, Trash2, Briefcase } from 'lucide-react'
import * as bibliothequeService from '@/api/bibliotheque'
import type { FicheMetierResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

interface MetierForm {
  titre: string
  resume: string
  contenu: string
  secteur: string
  missions: string
  competences: string
  formationsAcces: string
  debouchesTogo: string
  fourchetteSalaire: string
  estPublie: boolean
}

const emptyForm: MetierForm = {
  titre: '',
  resume: '',
  contenu: '',
  secteur: '',
  missions: '',
  competences: '',
  formationsAcces: '',
  debouchesTogo: '',
  fourchetteSalaire: '',
  estPublie: false,
}

const SECTEURS = [
  'Santé',
  'Éducation',
  'Technologie',
  'Agriculture',
  'Commerce',
  'Industrie',
  'BTP',
  'Transport',
  'Hôtellerie',
  'Finance',
  'Administration',
  'Artisanat',
  'Autre',
]

export default function MetiersPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [secteurFilter, setSecteurFilter] = useState('')
  const [selected, setSelected] = useState<FicheMetierResponse | null>(null)
  const [showCreate, setShowCreate] = useState(false)
  const [showEdit, setShowEdit] = useState(false)
  const [editing, setEditing] = useState<FicheMetierResponse | null>(null)
  const [form, setForm] = useState<MetierForm>(emptyForm)

  const { data, isLoading } = useQuery({
    queryKey: ['metiers', page, search, secteurFilter],
    queryFn: () => {
      if (search.trim()) {
        return bibliothequeService.searchMetiers(search, page - 1, 10)
      }
      return bibliothequeService.getAllMetiers(page - 1, 10)
    },
  })

  const createMutation = useMutation({
    mutationFn: (data: MetierForm) =>
      bibliothequeService.createMetier({
        titre: data.titre,
        resume: data.resume,
        contenu: data.contenu,
        estPublie: data.estPublie,
        secteur: data.secteur,
        missions: data.missions || undefined,
        competences: data.competences || undefined,
        formationsAcces: data.formationsAcces || undefined,
        debouchesTogo: data.debouchesTogo || undefined,
        fourchetteSalaire: data.fourchetteSalaire || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['metiers'] })
      setShowCreate(false)
      setForm(emptyForm)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<MetierForm> }) =>
      bibliothequeService.updateMetier(id, {
        titre: data.titre ?? '',
        resume: data.resume ?? '',
        contenu: data.contenu ?? '',
        estPublie: data.estPublie ?? false,
        secteur: data.secteur ?? '',
        missions: data.missions || undefined,
        competences: data.competences || undefined,
        formationsAcces: data.formationsAcces || undefined,
        debouchesTogo: data.debouchesTogo || undefined,
        fourchetteSalaire: data.fourchetteSalaire || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['metiers'] })
      setShowEdit(false)
      setEditing(null)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => bibliothequeService.deleteMetier(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['metiers'] })
      setSelected(null)
    },
  })

  function togglePublish(item: FicheMetierResponse) {
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

  function handleEdit(e: React.FormEvent) {
    e.preventDefault()
    if (!editing) return
    updateMutation.mutate({ id: editing.trackingId, data: form })
  }

  function openEditModal(item: FicheMetierResponse) {
    setEditing(item)
    setForm({
      titre: item.titre,
      resume: item.resume,
      contenu: '',
      secteur: item.secteur || '',
      missions: item.missions || '',
      competences: item.competences || '',
      formationsAcces: item.formationsAcces || '',
      debouchesTogo: item.debouchesTogo || '',
      fourchetteSalaire: item.fourchetteSalaire || '',
      estPublie: item.estPublie,
    })
    setShowEdit(true)
    setSelected(null)
  }

  const filteredData = (data?.content ?? []).filter((item) => {
    if (secteurFilter && item.secteur !== secteurFilter) return false
    return true
  })

  const columns = [
    { key: 'titre', label: 'Métier' },
    { key: 'secteur', label: 'Secteur' },
    {
      key: 'estPublie',
      label: 'Statut',
      render: (item: FicheMetierResponse) => (
        <StatusBadge status={item.estPublie ? 'PUBLIE' : 'BROUILLON'} />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: FicheMetierResponse) => (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => { e.stopPropagation(); togglePublish(item) }}
            className={`text-xs font-medium px-2.5 py-1 rounded-lg transition-colors ${
              item.estPublie
                ? 'bg-secondary-light text-secondary hover:bg-amber-200'
                : 'bg-success-light text-success hover:bg-emerald-200'
            }`}
          >
            {item.estPublie ? 'Dépublier' : 'Publier'}
          </button>
          <button
            onClick={(e) => { e.stopPropagation(); openEditModal(item) }}
            className="text-xs font-medium px-2.5 py-1 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors"
          >
            <Pencil className="size-3.5" />
          </button>
        </div>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestion des métiers"
        description={`${data?.totalElements ?? 0} métiers`}
        actions={
          <button
            onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouveau métier
          </button>
        }
      />

      <div className="flex items-center gap-4">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher un métier..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1) }}
            className="w-full pl-10 pr-4 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <select
            value={secteurFilter}
            onChange={(e) => { setSecteurFilter(e.target.value); setPage(1) }}
            className="pl-10 pr-8 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary appearance-none"
          >
            <option value="">Tous les secteurs</option>
            {SECTEURS.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={filteredData}
        loading={isLoading}
        onRowClick={(item) => setSelected(item)}
        pagination={data ? { page, totalPages: data.totalPages, onPageChange: setPage } : undefined}
      />

      {/* Detail modal */}
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
                <Briefcase className="size-8 text-gray-300" />
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-text-main">{selected.titre}</h3>
                <p className="text-sm text-text-secondary mt-1">{selected.resume}</p>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-light text-primary mt-2">
                  {selected.secteur}
                </span>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div className="col-span-2">
                <span className="text-text-secondary block">Missions</span>
                <span className="text-text-main font-medium">{selected.missions || '-'}</span>
              </div>
              <div className="col-span-2">
                <span className="text-text-secondary block">Compétences</span>
                <span className="text-text-main font-medium">{selected.competences || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Formations d'accès</span>
                <span className="text-text-main font-medium">{selected.formationsAcces || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Débouchés au Togo</span>
                <span className="text-text-main font-medium">{selected.debouchesTogo || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Fourchette salaire</span>
                <span className="text-text-main font-medium">{selected.fourchetteSalaire || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Filières préparantes</span>
                <span className="text-text-main font-medium">
                  {selected.filieresPreparantes?.length
                    ? selected.filieresPreparantes.map(f => f.titre).join(', ')
                    : '-'}
                </span>
              </div>
            </div>
            <div className="flex items-center justify-between pt-3 border-t border-border">
              <span className="text-sm text-text-secondary">
                Statut : <StatusBadge status={selected.estPublie ? 'PUBLIE' : 'BROUILLON'} />
              </span>
              <div className="flex gap-2">
                <button
                  onClick={() => { const s = selected; setSelected(null); openEditModal(s) }}
                  className="flex items-center gap-1 text-sm font-medium px-4 py-2 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors"
                >
                  <Pencil className="size-4" />
                  Modifier
                </button>
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
                <button
                  onClick={() => {
                    if (confirm('Supprimer ce métier ?')) {
                      deleteMutation.mutate(selected.trackingId)
                    }
                  }}
                  className="flex items-center gap-1 text-sm font-medium px-4 py-2 rounded-lg bg-danger-light text-danger hover:bg-red-200 transition-colors"
                >
                  <Trash2 className="size-4" />
                  Supprimer
                </button>
              </div>
            </div>
          </div>
        )}
      </Modal>

      {/* Create modal */}
      <Modal
        open={showCreate}
        onClose={() => { setShowCreate(false); setForm(emptyForm) }}
        title="Nouveau métier"
        size="lg"
      >
        <form onSubmit={handleCreate} className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Titre du métier</label>
            <input
              required
              value={form.titre}
              onChange={(e) => setForm(f => ({ ...f, titre: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Résumé</label>
            <textarea
              rows={3}
              value={form.resume}
              onChange={(e) => setForm(f => ({ ...f, resume: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Secteur</label>
            <select
              value={form.secteur}
              onChange={(e) => setForm(f => ({ ...f, secteur: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            >
              <option value="">Sélectionner un secteur</option>
              {SECTEURS.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Missions</label>
            <textarea
              rows={3}
              value={form.missions}
              onChange={(e) => setForm(f => ({ ...f, missions: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Compétences</label>
              <textarea
                rows={3}
                value={form.competences}
                onChange={(e) => setForm(f => ({ ...f, competences: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Formations d'accès</label>
              <textarea
                rows={3}
                value={form.formationsAcces}
                onChange={(e) => setForm(f => ({ ...f, formationsAcces: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Débouchés au Togo</label>
              <textarea
                rows={3}
                value={form.debouchesTogo}
                onChange={(e) => setForm(f => ({ ...f, debouchesTogo: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Fourchette de salaire</label>
              <input
                value={form.fourchetteSalaire}
                onChange={(e) => setForm(f => ({ ...f, fourchetteSalaire: e.target.value }))}
                placeholder="Ex: 200 000 - 500 000 FCFA"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="create-publie"
              checked={form.estPublie}
              onChange={(e) => setForm(f => ({ ...f, estPublie: e.target.checked }))}
              className="rounded border-border text-primary focus:ring-primary"
            />
            <label htmlFor="create-publie" className="text-sm text-text-main">Publié</label>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={() => { setShowCreate(false); setForm(emptyForm) }}
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

      {/* Edit modal */}
      <Modal
        open={showEdit}
        onClose={() => { setShowEdit(false); setEditing(null); setForm(emptyForm) }}
        title={editing ? `Modifier : ${editing.titre}` : 'Modifier'}
        size="lg"
      >
        <form onSubmit={handleEdit} className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Titre du métier</label>
            <input
              required
              value={form.titre}
              onChange={(e) => setForm(f => ({ ...f, titre: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Résumé</label>
            <textarea
              rows={3}
              value={form.resume}
              onChange={(e) => setForm(f => ({ ...f, resume: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Secteur</label>
            <select
              value={form.secteur}
              onChange={(e) => setForm(f => ({ ...f, secteur: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            >
              <option value="">Sélectionner un secteur</option>
              {SECTEURS.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Missions</label>
            <textarea
              rows={3}
              value={form.missions}
              onChange={(e) => setForm(f => ({ ...f, missions: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Compétences</label>
              <textarea
                rows={3}
                value={form.competences}
                onChange={(e) => setForm(f => ({ ...f, competences: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Formations d'accès</label>
              <textarea
                rows={3}
                value={form.formationsAcces}
                onChange={(e) => setForm(f => ({ ...f, formationsAcces: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Débouchés au Togo</label>
              <textarea
                rows={3}
                value={form.debouchesTogo}
                onChange={(e) => setForm(f => ({ ...f, debouchesTogo: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Fourchette de salaire</label>
              <input
                value={form.fourchetteSalaire}
                onChange={(e) => setForm(f => ({ ...f, fourchetteSalaire: e.target.value }))}
                placeholder="Ex: 200 000 - 500 000 FCFA"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="edit-publie"
              checked={form.estPublie}
              onChange={(e) => setForm(f => ({ ...f, estPublie: e.target.checked }))}
              className="rounded border-border text-primary focus:ring-primary"
            />
            <label htmlFor="edit-publie" className="text-sm text-text-main">Publié</label>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={() => { setShowEdit(false); setEditing(null); setForm(emptyForm) }}
              className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              type="submit"
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
        </form>
      </Modal>
    </div>
  )
}
