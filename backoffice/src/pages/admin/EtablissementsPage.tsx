import { useState, useRef } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, Plus, Filter, Save, Upload, X, Building2, Pencil } from 'lucide-react'
import * as bibliothequeService from '@/api/bibliotheque'
import api from '@/api/client'
import type { FicheEtablissementResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

interface EtablissementForm {
  titre: string
  resume: string
  contenu: string
  adresse: string
  ville: string
  typeEtablissement: string
  niveau: string
  contacts: string
  siteWeb: string
  offreFormation: string
  estPublic: boolean
  estPublie: boolean
}

const emptyForm: EtablissementForm = {
  titre: '',
  resume: '',
  contenu: '',
  adresse: '',
  ville: '',
  typeEtablissement: '',
  niveau: '',
  contacts: '',
  siteWeb: '',
  offreFormation: '',
  estPublic: true,
  estPublie: false,
}

const VILLES = ['Lomé', 'Kara', 'Sokodé', 'Kpalimé', 'Atakpamé', 'Tsévié']
const TYPES = ['UNIVERSITE', 'ECOLE_SUPERIEURE', 'LYCEE', 'COLLEGE', 'CENTRE_FORMATION_PROFESSIONNELLE', 'GRANDE_ECOLE', 'AUTRE']
const NIVEAUX = ['Primaire', 'Secondaire', 'Bac', 'Licence', 'Master', 'Doctorat', 'Formation professionnelle']

export default function EtablissementsPage() {
  const queryClient = useQueryClient()
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [villeFilter, setVilleFilter] = useState('')
  const [typeFilter, setTypeFilter] = useState('')
  const [niveauFilter, setNiveauFilter] = useState('')
  const [selected, setSelected] = useState<FicheEtablissementResponse | null>(null)
  const [showCreate, setShowCreate] = useState(false)
  const [showEdit, setShowEdit] = useState(false)
  const [editing, setEditing] = useState<FicheEtablissementResponse | null>(null)
  const [form, setForm] = useState<EtablissementForm>(emptyForm)
  const [selectedFiles, setSelectedFiles] = useState<File[]>([])
  const [uploading, setUploading] = useState(false)

  const { data, isLoading } = useQuery({
    queryKey: ['etablissements', page, search, villeFilter, typeFilter],
    queryFn: () => {
      if (search.trim()) {
        return bibliothequeService.searchEtablissements(search, page - 1, 10)
      }
      return bibliothequeService.getAllEtablissements(page - 1, 10)
    },
  })

  const createMutation = useMutation({
    mutationFn: (data: EtablissementForm) =>
      bibliothequeService.createEtablissement({
        titre: data.titre,
        resume: data.resume,
        contenu: data.contenu,
        estPublie: data.estPublie,
        adresse: data.adresse,
        ville: data.ville,
        typeEtablissement: data.typeEtablissement,
        niveau: data.niveau || undefined,
        contacts: data.contacts,
        siteWeb: data.siteWeb,
        offreFormation: data.offreFormation,
        estPublic: data.estPublic,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['etablissements'] })
      setShowCreate(false)
      setForm(emptyForm)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<EtablissementForm> }) =>
      bibliothequeService.updateEtablissement(id, {
        titre: data.titre ?? '',
        resume: data.resume ?? '',
        contenu: data.contenu ?? '',
        estPublie: data.estPublie ?? false,
        adresse: data.adresse ?? '',
        ville: data.ville ?? '',
        typeEtablissement: data.typeEtablissement ?? '',
        niveau: data.niveau || undefined,
        contacts: data.contacts,
        siteWeb: data.siteWeb,
        offreFormation: data.offreFormation,
        estPublic: data.estPublic ?? true,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['etablissements'] })
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => bibliothequeService.deleteEtablissement(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['etablissements'] })
      setSelected(null)
    },
  })

  async function handleUploadMedia() {
    if (!selected || selectedFiles.length === 0) return
    setUploading(true)
    try {
      const formData = new FormData()
      for (const file of selectedFiles) {
        if (file.type.startsWith('image/')) {
          formData.append('images', file)
        } else if (file.type.startsWith('video/')) {
          formData.append('videos', file)
        } else {
          formData.append('documents', file)
        }
      }
      await api.post(`/bibliotheque/etablissements/${selected.trackingId}/medias`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      queryClient.invalidateQueries({ queryKey: ['etablissements'] })
      setSelectedFiles([])
    } catch (e) {
      console.error('Upload failed', e)
    } finally {
      setUploading(false)
    }
  }

  function togglePublish(item: FicheEtablissementResponse) {
    updateMutation.mutate({
      id: item.trackingId,
      data: { estPublie: !item.estPublie },
    })
    setSelected(prev =>
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

  function openEditModal(item: FicheEtablissementResponse) {
    setEditing(item)
    setForm({
      titre: item.titre,
      resume: item.resume,
      contenu: item.contenu ?? '',
      adresse: item.adresse || '',
      ville: item.ville || '',
      typeEtablissement: item.typeEtablissement || '',
      niveau: item.niveau || '',
      contacts: item.contacts || '',
      siteWeb: item.siteWeb || '',
      offreFormation: item.offreFormation || '',
      estPublic: item.estPublic,
      estPublie: item.estPublie,
    })
    setShowEdit(true)
    setSelected(null)
  }

  const filteredData = (data?.content ?? []).filter((item) => {
    if (villeFilter && item.ville !== villeFilter) return false
    if (typeFilter && item.typeEtablissement !== typeFilter) return false
    if (niveauFilter && item.niveau !== niveauFilter) return false
    return true
  })

  const columns = [
    { key: 'titre', label: 'Établissement' },
    { key: 'ville', label: 'Ville' },
    { key: 'niveau', label: 'Niveau' },
    { key: 'typeEtablissement', label: 'Type' },
    {
      key: 'estPublic',
      label: 'Statut',
      render: (item: FicheEtablissementResponse) => (
        <StatusBadge status={item.estPublic ? 'PUBLIE' : 'PRIVÉ'} />
      ),
    },
    {
      key: 'media',
      label: 'Médias',
      render: (item: FicheEtablissementResponse) => (
        <span className="text-text-secondary text-xs">
          {item.imageUrls?.length ?? 0} img · {item.videoUrls?.length ?? 0} vid
        </span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: FicheEtablissementResponse) => (
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
        title="Gestion des établissements"
        description={`${data?.totalElements ?? 0} établissements`}
        actions={
          <button
            onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouvel établissement
          </button>
        }
      />

      <div className="flex items-center gap-4">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher un établissement..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1) }}
            className="w-full pl-10 pr-4 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <select
            value={villeFilter}
            onChange={(e) => { setVilleFilter(e.target.value); setPage(1) }}
            className="pl-10 pr-8 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary appearance-none"
          >
            <option value="">Toutes les villes</option>
            {VILLES.map((v) => <option key={v} value={v}>{v}</option>)}
          </select>
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <select
            value={typeFilter}
            onChange={(e) => { setTypeFilter(e.target.value); setPage(1) }}
            className="pl-10 pr-8 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary appearance-none"
          >
            <option value="">Tous les types</option>
            {TYPES.map((t) => <option key={t} value={t}>{t.replace(/_/g, ' ')}</option>)}
          </select>
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <select
            value={niveauFilter}
            onChange={(e) => { setNiveauFilter(e.target.value); setPage(1) }}
            className="pl-10 pr-8 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary appearance-none"
          >
            <option value="">Tous les niveaux</option>
            {NIVEAUX.map((n) => <option key={n} value={n}>{n}</option>)}
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
        onClose={() => { setSelected(null); setSelectedFiles([]) }}
        title={selected?.titre ?? 'Détails'}
        size="lg"
      >
        {selected && (
          <div className="space-y-5">
            <div className="flex items-start gap-4">
              <div className="w-24 h-24 rounded-xl bg-gray-100 flex items-center justify-center shrink-0 overflow-hidden">
                {selected.imageUrls?.length ? (
                  <img src={selected.imageUrls[0]} alt="" className="w-full h-full object-cover" />
                ) : (
                  <Building2 className="size-8 text-gray-300" />
                )}
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-text-main">{selected.titre}</h3>
                <p className="text-sm text-text-secondary mt-1">{selected.resume}</p>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-light text-primary mt-2">
                  {selected.typeEtablissement.replace(/_/g, ' ')}
                </span>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-50 text-blue-600 mt-2 ml-2">
                  {selected.ville}
                </span>
                {selected.niveau && (
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-50 text-purple-600 mt-2 ml-2">
                    {selected.niveau}
                  </span>
                )}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-text-secondary block">Adresse</span>
                <span className="text-text-main font-medium">{selected.adresse || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Ville</span>
                <span className="text-text-main font-medium">{selected.ville || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Niveau</span>
                <span className="text-text-main font-medium">{selected.niveau || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Contacts</span>
                <span className="text-text-main font-medium">{selected.contacts || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Site web</span>
                <span className="text-text-main font-medium">{selected.siteWeb || '-'}</span>
              </div>
              <div>
                <span className="text-text-secondary block">Consultations</span>
                <span className="text-text-main font-medium">{selected.nbConsultations ?? 0}</span>
              </div>
              {selected.offreFormation && (
                <div className="col-span-2">
                  <span className="text-text-secondary block">Offre de formation</span>
                  <span className="text-text-main font-medium">{selected.offreFormation}</span>
                </div>
              )}
              {selected.contenu && (
                <div className="col-span-2">
                  <span className="text-text-secondary block">Contenu détaillé</span>
                  <span className="text-text-main font-medium text-xs">{selected.contenu}</span>
                </div>
              )}
            </div>

            {selected.filieresProposees && selected.filieresProposees.length > 0 && (
              <div>
                <h4 className="text-sm font-semibold text-text-main mb-2">
                  Filières proposées ({selected.filieresProposees.length})
                </h4>
                <div className="flex flex-wrap gap-2">
                  {selected.filieresProposees.map((f) => (
                    <span key={f.trackingId} className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-50 text-green-700">
                      {f.titre}
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Media gallery */}
            {(selected.imageUrls?.length > 0 || selected.videoUrls?.length > 0 || selected.documentUrls?.length > 0) && (
              <div>
                <h4 className="text-sm font-semibold text-text-main mb-2">Médias</h4>
                <div className="flex gap-2 flex-wrap">
                  {selected.imageUrls?.map((url, i) => (
                    <a key={i} href={url} target="_blank" rel="noreferrer"
                      className="w-20 h-20 rounded-lg overflow-hidden border border-border bg-gray-50">
                      <img src={url} alt="" className="w-full h-full object-cover" />
                    </a>
                  ))}
                  {selected.videoUrls?.map((url, i) => (
                    <a key={i} href={url} target="_blank" rel="noreferrer"
                      className="w-20 h-20 rounded-lg overflow-hidden border border-border bg-gray-50 flex items-center justify-center text-xs text-text-secondary">
                      Vidéo {i + 1}
                    </a>
                  ))}
                  {selected.documentUrls?.map((url, i) => (
                    <a key={i} href={url} target="_blank" rel="noreferrer"
                      className="w-20 h-20 rounded-lg overflow-hidden border border-border bg-gray-50 flex items-center justify-center text-xs text-text-secondary">
                      PDF {i + 1}
                    </a>
                  ))}
                </div>
              </div>
            )}

            {/* Upload media */}
            <div className="border-t border-border pt-4">
              <h4 className="text-sm font-semibold text-text-main mb-2">Ajouter des médias</h4>
              <div className="flex items-center gap-3">
                <button
                  onClick={() => fileInputRef.current?.click()}
                  className="flex items-center gap-2 px-4 py-2 border border-border rounded-lg text-sm text-text-secondary hover:bg-gray-50 transition-colors"
                >
                  <Upload className="size-4" />
                  Choisir des fichiers
                </button>
                <input
                  ref={fileInputRef}
                  type="file"
                  multiple
                  accept="image/*,video/*,.pdf"
                  className="hidden"
                  onChange={(e) => setSelectedFiles(Array.from(e.target.files ?? []))}
                />
                {selectedFiles.length > 0 && (
                  <div className="flex items-center gap-2 flex-1">
                    <span className="text-xs text-text-secondary">{selectedFiles.length} fichier(s)</span>
                    <button
                      onClick={handleUploadMedia}
                      disabled={uploading}
                      className="flex items-center gap-1 px-3 py-1.5 bg-primary text-white text-xs font-medium rounded-lg hover:bg-primary-dark disabled:opacity-50 transition-colors"
                    >
                      {uploading ? (
                        <span className="size-3 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      ) : (
                        <Save className="size-3" />
                      )}
                      Upload
                    </button>
                    <button
                      onClick={() => setSelectedFiles([])}
                      className="p-1.5 text-text-secondary hover:text-text-main rounded-lg hover:bg-gray-100"
                    >
                      <X className="size-4" />
                    </button>
                  </div>
                )}
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
                    if (confirm('Supprimer cet établissement ?')) {
                      deleteMutation.mutate(selected.trackingId)
                    }
                  }}
                  className="text-sm font-medium px-4 py-2 rounded-lg bg-danger-light text-danger hover:bg-red-200 transition-colors"
                >
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
        title="Nouvel établissement"
        size="lg"
      >
        <form onSubmit={handleCreate} className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Nom de l'établissement</label>
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
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Ville</label>
              <select
                value={form.ville}
                onChange={(e) => setForm(f => ({ ...f, ville: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              >
                <option value="">Sélectionner une ville</option>
                {VILLES.map(v => <option key={v} value={v}>{v}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Niveau</label>
              <select
                value={form.niveau}
                onChange={(e) => setForm(f => ({ ...f, niveau: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              >
                <option value="">Sélectionner un niveau</option>
                {NIVEAUX.map(n => <option key={n} value={n}>{n}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Type</label>
              <select
                value={form.typeEtablissement}
                onChange={(e) => setForm(f => ({ ...f, typeEtablissement: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              >
                <option value="">Sélectionner un type</option>
                {TYPES.map(t => <option key={t} value={t}>{t}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Adresse</label>
            <input
              value={form.adresse}
              onChange={(e) => setForm(f => ({ ...f, adresse: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Contacts</label>
              <input
                value={form.contacts}
                onChange={(e) => setForm(f => ({ ...f, contacts: e.target.value }))}
                placeholder="Téléphone / Email"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Site web</label>
              <input
                value={form.siteWeb}
                onChange={(e) => setForm(f => ({ ...f, siteWeb: e.target.value }))}
                placeholder="https://example.tg"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Contenu détaillé</label>
            <textarea
              rows={4}
              value={form.contenu}
              onChange={(e) => setForm(f => ({ ...f, contenu: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Offre de formation</label>
            <textarea
              rows={4}
              value={form.offreFormation}
              onChange={(e) => setForm(f => ({ ...f, offreFormation: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="flex items-center gap-6">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.estPublic}
                onChange={(e) => setForm(f => ({ ...f, estPublic: e.target.checked }))}
                className="rounded border-border text-primary focus:ring-primary"
              />
              <span className="text-sm text-text-main">Établissement public</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.estPublie}
                onChange={(e) => setForm(f => ({ ...f, estPublie: e.target.checked }))}
                className="rounded border-border text-primary focus:ring-primary"
              />
              <span className="text-sm text-text-main">Publié</span>
            </label>
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
            <label className="block text-sm font-medium text-text-main mb-1">Nom de l'établissement</label>
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
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Ville</label>
              <select
                value={form.ville}
                onChange={(e) => setForm(f => ({ ...f, ville: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              >
                <option value="">Sélectionner une ville</option>
                {VILLES.map(v => <option key={v} value={v}>{v}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Niveau</label>
              <select
                value={form.niveau}
                onChange={(e) => setForm(f => ({ ...f, niveau: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              >
                <option value="">Sélectionner un niveau</option>
                {NIVEAUX.map(n => <option key={n} value={n}>{n}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Type</label>
              <select
                value={form.typeEtablissement}
                onChange={(e) => setForm(f => ({ ...f, typeEtablissement: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              >
                <option value="">Sélectionner un type</option>
                {TYPES.map(t => <option key={t} value={t}>{t}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Adresse</label>
            <input
              value={form.adresse}
              onChange={(e) => setForm(f => ({ ...f, adresse: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Contacts</label>
              <input
                value={form.contacts}
                onChange={(e) => setForm(f => ({ ...f, contacts: e.target.value }))}
                placeholder="Téléphone / Email"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Site web</label>
              <input
                value={form.siteWeb}
                onChange={(e) => setForm(f => ({ ...f, siteWeb: e.target.value }))}
                placeholder="https://example.tg"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Contenu détaillé</label>
            <textarea
              rows={4}
              value={form.contenu}
              onChange={(e) => setForm(f => ({ ...f, contenu: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Offre de formation</label>
            <textarea
              rows={4}
              value={form.offreFormation}
              onChange={(e) => setForm(f => ({ ...f, offreFormation: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="flex items-center gap-6">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.estPublic}
                onChange={(e) => setForm(f => ({ ...f, estPublic: e.target.checked }))}
                className="rounded border-border text-primary focus:ring-primary"
              />
              <span className="text-sm text-text-main">Établissement public</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.estPublie}
                onChange={(e) => setForm(f => ({ ...f, estPublie: e.target.checked }))}
                className="rounded border-border text-primary focus:ring-primary"
              />
              <span className="text-sm text-text-main">Publié</span>
            </label>
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
