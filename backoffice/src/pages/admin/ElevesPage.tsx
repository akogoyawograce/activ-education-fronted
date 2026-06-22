import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, UserPlus, Pencil, Download, Upload } from 'lucide-react'
import * as eleveService from '@/api/eleves'
import type { EleveResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import UserAvatar from '@/components/ui/UserAvatar'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

interface EleveForm {
  nom: string
  prenom: string
  email: string
  telephone: string
  motDePasse: string
  niveauEtude: string
  etablissementActuel: string
  filiere: string
  typeApprenant: string
}

const emptyForm: EleveForm = {
  nom: '',
  prenom: '',
  email: '',
  telephone: '',
  motDePasse: '',
  niveauEtude: '',
  etablissementActuel: '',
  filiere: '',
  typeApprenant: '',
}

export default function ElevesPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState<EleveResponse | null>(null)
  const [showCreate, setShowCreate] = useState(false)
  const [showEdit, setShowEdit] = useState(false)
  const [editing, setEditing] = useState<EleveResponse | null>(null)
  const [form, setForm] = useState<EleveForm>(emptyForm)

  const { data, isLoading } = useQuery({
    queryKey: ['eleves', page, search],
    queryFn: () => eleveService.getAll(page - 1, 10),
  })

  const createMutation = useMutation({
    mutationFn: (data: EleveForm) =>
      eleveService.create({
        nom: data.nom,
        prenom: data.prenom,
        email: data.email,
        telephone: data.telephone || undefined,
        motDePasse: data.motDePasse,
        niveauEtude: data.niveauEtude || undefined,
        etablissementActuel: data.etablissementActuel || undefined,
        filiere: data.filiere || undefined,
        typeApprenant: data.typeApprenant,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['eleves'] })
      setShowCreate(false)
      setForm(emptyForm)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: EleveForm }) =>
      eleveService.update(id, {
        nom: data.nom,
        prenom: data.prenom,
        email: data.email,
        telephone: data.telephone || undefined,
        motDePasse: data.motDePasse || 'default123',
        niveauEtude: data.niveauEtude || undefined,
        etablissementActuel: data.etablissementActuel || undefined,
        filiere: data.filiere || undefined,
        typeApprenant: data.typeApprenant,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['eleves'] })
      setShowEdit(false)
      setEditing(null)
      setForm(emptyForm)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => eleveService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['eleves'] })
      setSelected(null)
    },
  })

  function handleCreate(e: React.FormEvent) {
    e.preventDefault()
    createMutation.mutate(form)
  }

  function handleEdit(e: React.FormEvent) {
    e.preventDefault()
    if (!editing) return
    updateMutation.mutate({ id: editing.trackingId, data: form })
  }

  function openEditModal(item: EleveResponse) {
    setEditing(item)
    setForm({
      nom: item.nom,
      prenom: item.prenom,
      email: item.email,
      telephone: item.telephone || '',
      motDePasse: '',
      niveauEtude: item.niveauEtude || '',
      etablissementActuel: item.etablissementActuel || '',
      filiere: item.filiere || '',
      typeApprenant: item.typeApprenant || '',
    })
    setShowEdit(true)
    setSelected(null)
  }

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
          <div className="flex items-center gap-2">
            <a
              href={`${import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/api/v1'}/admin/export/eleves`}
              className="flex items-center gap-2 border border-border hover:bg-gray-50 text-text-secondary text-sm font-medium px-4 py-2 rounded-lg transition-colors"
            >
              <Download className="size-4" />
              Export CSV
            </a>
            <label className="flex items-center gap-2 border border-border hover:bg-gray-50 text-text-secondary text-sm font-medium px-4 py-2 rounded-lg transition-colors cursor-pointer">
              <Upload className="size-4" />
              Import CSV
              <input
                type="file"
                accept=".csv"
                className="hidden"
                onChange={async (e) => {
                  const file = e.target.files?.[0]
                  if (!file) return
                  const formData = new FormData()
                  formData.append('file', file)
                  try {
                    const base = (import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/api/v1')
                    const res = await fetch(`${base}/admin/import/eleves`, { method: 'POST', body: formData })
                    const result = await res.json()
                    alert(`Importé: ${result.imported} / ${result.total} élèves`)
                    queryClient.invalidateQueries({ queryKey: ['eleves'] })
                  } catch (err) {
                    alert('Erreur import: ' + err)
                  }
                }}
              />
            </label>
            <button
              onClick={() => setShowCreate(true)}
              className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
            >
              <UserPlus className="size-4" />
              Nouvel élève
            </button>
          </div>
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

      {/* Detail modal */}
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

            <div className="flex items-center justify-between pt-4 border-t border-border">
              <span className="text-sm text-text-secondary">
                {selected.actif ? 'Compte actif' : 'Compte inactif'}
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
                  onClick={() => {
                    if (confirm('Supprimer cet élève ?')) {
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
        title="Nouvel élève"
        size="lg"
      >
        <form onSubmit={handleCreate} className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Nom</label>
              <input
                required
                value={form.nom}
                onChange={(e) => setForm(f => ({ ...f, nom: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Prénom</label>
              <input
                required
                value={form.prenom}
                onChange={(e) => setForm(f => ({ ...f, prenom: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Email</label>
              <input
                type="email"
                required
                value={form.email}
                onChange={(e) => setForm(f => ({ ...f, email: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Téléphone</label>
              <input
                value={form.telephone}
                onChange={(e) => setForm(f => ({ ...f, telephone: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">
              Mot de passe <span className="text-danger">*</span>
            </label>
            <input
              type="password"
              required
              minLength={8}
              value={form.motDePasse}
              onChange={(e) => setForm(f => ({ ...f, motDePasse: e.target.value }))}
              placeholder="Min. 8 caractères"
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Niveau d'étude</label>
              <input
                value={form.niveauEtude}
                onChange={(e) => setForm(f => ({ ...f, niveauEtude: e.target.value }))}
                placeholder="Ex: Terminale, Licence 3"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Type d'apprenant</label>
              <input
                required
                value={form.typeApprenant}
                onChange={(e) => setForm(f => ({ ...f, typeApprenant: e.target.value }))}
                placeholder="Ex: Scolaire, Universitaire"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Établissement actuel</label>
            <input
              value={form.etablissementActuel}
              onChange={(e) => setForm(f => ({ ...f, etablissementActuel: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Filière</label>
            <input
              value={form.filiere}
              onChange={(e) => setForm(f => ({ ...f, filiere: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
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
              ) : null}
              Créer
            </button>
          </div>
        </form>
      </Modal>

      {/* Edit modal */}
      <Modal
        open={showEdit}
        onClose={() => { setShowEdit(false); setEditing(null); setForm(emptyForm) }}
        title={editing ? `Modifier : ${editing.prenom} ${editing.nom}` : 'Modifier'}
        size="lg"
      >
        <form onSubmit={handleEdit} className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Nom</label>
              <input
                required
                value={form.nom}
                onChange={(e) => setForm(f => ({ ...f, nom: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Prénom</label>
              <input
                required
                value={form.prenom}
                onChange={(e) => setForm(f => ({ ...f, prenom: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Email</label>
              <input
                type="email"
                required
                value={form.email}
                onChange={(e) => setForm(f => ({ ...f, email: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Téléphone</label>
              <input
                value={form.telephone}
                onChange={(e) => setForm(f => ({ ...f, telephone: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Niveau d'étude</label>
              <input
                value={form.niveauEtude}
                onChange={(e) => setForm(f => ({ ...f, niveauEtude: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Type d'apprenant</label>
              <input
                required
                value={form.typeApprenant}
                onChange={(e) => setForm(f => ({ ...f, typeApprenant: e.target.value }))}
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Établissement actuel</label>
            <input
              value={form.etablissementActuel}
              onChange={(e) => setForm(f => ({ ...f, etablissementActuel: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Filière</label>
            <input
              value={form.filiere}
              onChange={(e) => setForm(f => ({ ...f, filiere: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
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
              ) : null}
              Enregistrer
            </button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
