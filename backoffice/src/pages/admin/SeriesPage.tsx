import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, Plus, Filter, Save, Pencil, Trash2, Book } from 'lucide-react'
import * as bibliothequeService from '@/api/bibliotheque'
import type { FicheSerieResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

interface SerieForm {
  titre: string
  resume: string
  contenu: string
  niveau: string
  matieresPrincipales: string
  debouches: string
  coefficients: string
  estPublie: boolean
}

const emptyForm: SerieForm = {
  titre: '',
  resume: '',
  contenu: '',
  niveau: '',
  matieresPrincipales: '',
  debouches: '',
  coefficients: '',
  estPublie: false,
}

const NIVEAUX_SERIE = ['Bac', 'Licence', 'Master', 'Doctorat', 'Secondaire']

export default function SeriesPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [niveauFilter, setNiveauFilter] = useState('')
  const [selected, setSelected] = useState<FicheSerieResponse | null>(null)
  const [showCreate, setShowCreate] = useState(false)
  const [showEdit, setShowEdit] = useState(false)
  const [editing, setEditing] = useState<FicheSerieResponse | null>(null)
  const [form, setForm] = useState<SerieForm>(emptyForm)

  const { data, isLoading } = useQuery({
    queryKey: ['series', page, search, niveauFilter],
    queryFn: () => {
      if (search.trim()) {
        return bibliothequeService.searchSeries(search, page - 1, 10)
      }
      return bibliothequeService.getAllSeries(page - 1, 10)
    },
  })

  const createMutation = useMutation({
    mutationFn: (data: SerieForm) =>
      bibliothequeService.createSerie({
        titre: data.titre,
        resume: data.resume,
        contenu: data.contenu,
        estPublie: data.estPublie,
        niveau: data.niveau,
        matieresPrincipales: data.matieresPrincipales || undefined,
        debouches: data.debouches || undefined,
        coefficients: data.coefficients || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['series'] })
      setShowCreate(false)
      setForm(emptyForm)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<SerieForm> }) =>
      bibliothequeService.updateSerie(id, {
        titre: data.titre ?? '',
        resume: data.resume ?? '',
        contenu: data.contenu ?? '',
        estPublie: data.estPublie ?? false,
        niveau: data.niveau ?? '',
        matieresPrincipales: data.matieresPrincipales || undefined,
        debouches: data.debouches || undefined,
        coefficients: data.coefficients || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['series'] })
      setShowEdit(false)
      setEditing(null)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => bibliothequeService.deleteSerie(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['series'] })
      setSelected(null)
    },
  })

  function togglePublish(item: FicheSerieResponse) {
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

  function openEditModal(item: FicheSerieResponse) {
    setEditing(item)
    setForm({
      titre: item.titre,
      resume: item.resume,
      contenu: '',
      niveau: item.niveau || '',
      matieresPrincipales: item.matieresPrincipales || '',
      debouches: item.debouches || '',
      coefficients: item.coefficients || '',
      estPublie: item.estPublie,
    })
    setShowEdit(true)
    setSelected(null)
  }

  const filteredData = (data?.content ?? []).filter((item) => {
    if (niveauFilter && item.niveau !== niveauFilter) return false
    return true
  })

  const columns = [
    { key: 'titre', label: 'Série' },
    { key: 'niveau', label: 'Niveau' },
    {
      key: 'estPublie',
      label: 'Statut',
      render: (item: FicheSerieResponse) => (
        <StatusBadge status={item.estPublie ? 'PUBLIE' : 'BROUILLON'} />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: FicheSerieResponse) => (
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
        title="Gestion des séries"
        description={`${data?.totalElements ?? 0} séries`}
        actions={
          <button
            onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouvelle série
          </button>
        }
      />

      <div className="flex items-center gap-4">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher une série..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1) }}
            className="w-full pl-10 pr-4 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <select
            value={niveauFilter}
            onChange={(e) => { setNiveauFilter(e.target.value); setPage(1) }}
            className="pl-10 pr-8 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary appearance-none"
          >
            <option value="">Tous les niveaux</option>
            {NIVEAUX_SERIE.map((n) => <option key={n} value={n}>{n}</option>)}
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
                <Book className="size-8 text-gray-300" />
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-text-main">{selected.titre}</h3>
                <p className="text-sm text-text-secondary mt-1">{selected.resume}</p>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-light text-primary mt-2">
                  {selected.niveau}
                </span>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div className="col-span-2">
                <span className="text-text-secondary block">Matières principales</span>
                <span className="text-text-main font-medium">{selected.matieresPrincipales || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Coefficients</span>
                <span className="text-text-main font-medium">{selected.coefficients || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Débouchés</span>
                <span className="text-text-main font-medium">{selected.debouches || '-'}</span>
              </div>
              <div className="col-span-2">
                <span className="text-text-secondary block">Filières associées</span>
                <span className="text-text-main font-medium">
                  {selected.filieresAssociees?.length
                    ? selected.filieresAssociees.map(f => f.titre).join(', ')
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
                    if (confirm('Supprimer cette série ?')) {
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
        title="Nouvelle série"
        size="lg"
      >
        <form onSubmit={handleCreate} className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Nom de la série</label>
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
            <label className="block text-sm font-medium text-text-main mb-1">Niveau</label>
            <select
              value={form.niveau}
              onChange={(e) => setForm(f => ({ ...f, niveau: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            >
              <option value="">Sélectionner un niveau</option>
              {NIVEAUX_SERIE.map(n => <option key={n} value={n}>{n}</option>)}
            </select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Matières principales</label>
              <textarea
                rows={3}
                value={form.matieresPrincipales}
                onChange={(e) => setForm(f => ({ ...f, matieresPrincipales: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Coefficients</label>
              <textarea
                rows={3}
                value={form.coefficients}
                onChange={(e) => setForm(f => ({ ...f, coefficients: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Débouchés</label>
            <textarea
              rows={3}
              value={form.debouches}
              onChange={(e) => setForm(f => ({ ...f, debouches: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
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
            <label className="block text-sm font-medium text-text-main mb-1">Nom de la série</label>
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
            <label className="block text-sm font-medium text-text-main mb-1">Niveau</label>
            <select
              value={form.niveau}
              onChange={(e) => setForm(f => ({ ...f, niveau: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            >
              <option value="">Sélectionner un niveau</option>
              {NIVEAUX_SERIE.map(n => <option key={n} value={n}>{n}</option>)}
            </select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Matières principales</label>
              <textarea
                rows={3}
                value={form.matieresPrincipales}
                onChange={(e) => setForm(f => ({ ...f, matieresPrincipales: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Coefficients</label>
              <textarea
                rows={3}
                value={form.coefficients}
                onChange={(e) => setForm(f => ({ ...f, coefficients: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Débouchés</label>
            <textarea
              rows={3}
              value={form.debouches}
              onChange={(e) => setForm(f => ({ ...f, debouches: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
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
