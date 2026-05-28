import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, UserPlus, Pencil, Trash2, AlertTriangle, CheckCircle, Copy, Link2, X } from 'lucide-react'
import * as parentService from '@/api/parents'
import * as eleveService from '@/api/eleves'
import type { ParentResponse } from '@/types'
import DataTable from '@/components/ui/DataTable'
import UserAvatar from '@/components/ui/UserAvatar'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'

interface ParentForm {
  nom: string
  prenom: string
  email: string
  telephone: string
  motDePasse: string
}

const emptyForm: ParentForm = {
  nom: '',
  prenom: '',
  email: '',
  telephone: '',
  motDePasse: '',
}

export default function ParentsPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState<ParentResponse | null>(null)
  const [modalMode, setModalMode] = useState<'create' | 'edit' | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<ParentResponse | null>(null)
  const [editTarget, setEditTarget] = useState<ParentResponse | null>(null)
  const [form, setForm] = useState<ParentForm>(emptyForm)
  const [error, setError] = useState('')
  const [createdTrackingId, setCreatedTrackingId] = useState('')
  const [copied, setCopied] = useState(false)
  const [linkId, setLinkId] = useState('')

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

  const createMutation = useMutation({
    mutationFn: (data: ParentForm) =>
      parentService.create({
        nom: data.nom,
        prenom: data.prenom,
        email: data.email,
        telephone: data.telephone,
        motDePasse: data.motDePasse || 'default123',
      }),
    onSuccess: (result) => {
      setCreatedTrackingId(result.trackingId)
      setError('')
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : 'Erreur lors de la création')
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: ParentForm }) =>
      parentService.update(id, {
        nom: data.nom,
        prenom: data.prenom,
        email: data.email,
        telephone: data.telephone,
        motDePasse: data.motDePasse || 'default123',
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['parents'] })
      setModalMode(null)
      setForm(emptyForm)
      setError('')
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : 'Erreur lors de la modification')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => parentService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['parents'] })
      setDeleteTarget(null)
      setSelected(null)
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : 'Erreur lors de la suppression')
    },
  })

  const linkMutation = useMutation({
    mutationFn: ({ parentId, eleveId }: { parentId: string; eleveId: string }) =>
      parentService.linkEnfant(parentId, eleveId),
    onSuccess: (result) => {
      queryClient.invalidateQueries({ queryKey: ['parents'] })
      setSelected(result)
      setLinkId('')
      setError('')
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : "Erreur lors du lien de l'enfant")
    },
  })

  const unlinkMutation = useMutation({
    mutationFn: ({ parentId, eleveId }: { parentId: string; eleveId: string }) =>
      parentService.unlinkEnfant(parentId, eleveId),
    onSuccess: (result) => {
      queryClient.invalidateQueries({ queryKey: ['parents'] })
      setSelected(result)
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : "Erreur lors du détachement de l'enfant")
    },
  })

  function openCreate() {
    setForm(emptyForm)
    setEditTarget(null)
    setModalMode('create')
    setError('')
    setCreatedTrackingId('')
    setCopied(false)
  }

  function openEdit(item: ParentResponse) {
    setEditTarget(item)
    setForm({
      nom: item.nom,
      prenom: item.prenom,
      email: item.email,
      telephone: item.telephone,
      motDePasse: '',
    })
    setModalMode('edit')
    setError('')
    setCreatedTrackingId('')
    setCopied(false)
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError('')
    setCreatedTrackingId('')
    if (modalMode === 'create') {
      createMutation.mutate(form)
    } else if (modalMode === 'edit' && editTarget) {
      updateMutation.mutate({ id: editTarget.trackingId, data: form })
    }
  }

  function closeModal() {
    setModalMode(null)
    setEditTarget(null)
    setForm(emptyForm)
    setError('')
    setCreatedTrackingId('')
    setCopied(false)
  }

  function copyTrackingId() {
    navigator.clipboard.writeText(createdTrackingId)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  function handleDelete() {
    if (deleteTarget) {
      deleteMutation.mutate(deleteTarget.trackingId)
    }
  }

  function handleLink() {
    if (selected && linkId.trim()) {
      linkMutation.mutate({ parentId: selected.trackingId, eleveId: linkId.trim() })
    }
  }

  function handleUnlink(eleveId: string) {
    if (selected) {
      unlinkMutation.mutate({ parentId: selected.trackingId, eleveId })
    }
  }

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
    {
      key: 'actions',
      label: '',
      render: (item: ParentResponse) => (
        <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
          <button
            onClick={() => openEdit(item)}
            className="p-1.5 rounded-lg hover:bg-primary-light text-text-secondary hover:text-primary transition-colors"
            title="Modifier"
          >
            <Pencil className="size-4" />
          </button>
          <button
            onClick={() => setDeleteTarget(item)}
            className="p-1.5 rounded-lg hover:bg-danger-light text-text-secondary hover:text-danger transition-colors"
            title="Supprimer"
          >
            <Trash2 className="size-4" />
          </button>
        </div>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestion des parents"
        description={`${data?.totalElements ?? 0} parents inscrits`}
        actions={
          <button
            onClick={openCreate}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
          >
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
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-text-main">
                  {selected.prenom} {selected.nom}
                </h3>
                <p className="text-sm text-text-secondary">{selected.email}</p>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => { setSelected(null); openEdit(selected) }}
                  className="p-2 rounded-lg hover:bg-primary-light text-text-secondary hover:text-primary transition-colors"
                  title="Modifier"
                >
                  <Pencil className="size-4" />
                </button>
                <button
                  onClick={() => setDeleteTarget(selected)}
                  className="p-2 rounded-lg hover:bg-danger-light text-text-secondary hover:text-danger transition-colors"
                  title="Supprimer"
                >
                  <Trash2 className="size-4" />
                </button>
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
                      <span className="text-text-main flex-1">
                        {childrenMap?.[id] ?? 'Chargement...'}
                      </span>
                      <button
                        onClick={() => handleUnlink(id)}
                        disabled={unlinkMutation.isPending}
                        className="p-1 rounded-lg hover:bg-danger-light text-text-secondary hover:text-danger transition-colors disabled:opacity-50"
                        title="Retirer l'enfant"
                      >
                        <X className="size-3.5" />
                      </button>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-text-secondary">Aucun enfant lié</p>
              )}
            </div>
            <div className="pt-3 border-t border-border">
              <h4 className="text-sm font-semibold text-text-main mb-3">Ajouter un enfant</h4>
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={linkId}
                  onChange={(e) => setLinkId(e.target.value)}
                  placeholder="Tracking ID de l'élève"
                  className="flex-1 px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                />
                <button
                  onClick={handleLink}
                  disabled={!linkId.trim() || linkMutation.isPending}
                  className="flex items-center gap-1.5 px-3 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50"
                >
                  <Link2 className="size-4" />
                  Lier
                </button>
              </div>
              {error && (
                <p className="text-xs text-danger mt-1">{error}</p>
              )}
            </div>
          </div>
        )}
      </Modal>

      <Modal
        open={modalMode !== null}
        onClose={closeModal}
        title={modalMode === 'create' ? 'Nouveau parent' : 'Modifier le parent'}
        size="md"
      >
        {createdTrackingId ? (
          <div className="space-y-4">
            <div className="flex items-center gap-3 text-green-700 bg-green-50 px-4 py-3 rounded-lg">
              <CheckCircle className="size-5 shrink-0" />
              <p className="text-sm font-medium">
                Parent créé avec succès !
              </p>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">
                Identifiant (trackingId)
              </label>
              <div className="flex items-center gap-2">
                <code className="flex-1 px-3 py-2 bg-gray-50 border border-border rounded-lg text-sm font-mono select-all">
                  {createdTrackingId}
                </code>
                <button
                  type="button"
                  onClick={copyTrackingId}
                  className="p-2 border border-border rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <Copy className="size-4 text-text-secondary" />
                </button>
              </div>
              {copied && (
                <p className="text-xs text-green-600 mt-1">Copié !</p>
              )}
            </div>
            <div className="flex justify-end">
              <button
                onClick={closeModal}
                className="px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors"
              >
                Terminé
              </button>
            </div>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-text-main mb-1">Nom</label>
                <input
                  required
                  value={form.nom}
                  onChange={(e) => setForm((f) => ({ ...f, nom: e.target.value }))}
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-main mb-1">Prénom</label>
                <input
                  required
                  value={form.prenom}
                  onChange={(e) => setForm((f) => ({ ...f, prenom: e.target.value }))}
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
                  onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-main mb-1">Téléphone</label>
                <input
                  value={form.telephone}
                  onChange={(e) => setForm((f) => ({ ...f, telephone: e.target.value }))}
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                />
              </div>
            </div>
            {modalMode === 'create' && (
              <div>
                <label className="block text-sm font-medium text-text-main mb-1">
                  Mot de passe <span className="text-danger">*</span>
                </label>
                <input
                  type="password"
                  required
                  minLength={8}
                  value={form.motDePasse}
                  onChange={(e) => setForm((f) => ({ ...f, motDePasse: e.target.value }))}
                  placeholder="Min. 8 caractères"
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                />
              </div>
            )}
            {modalMode === 'edit' && (
              <div>
                <label className="block text-sm font-medium text-text-main mb-1">
                  Mot de passe <span className="text-text-secondary">(optionnel)</span>
                </label>
                <input
                  type="password"
                  value={form.motDePasse}
                  onChange={(e) => setForm((f) => ({ ...f, motDePasse: e.target.value }))}
                  placeholder="Laisser vide pour conserver l'actuel"
                  className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                />
              </div>
            )}
            {error && (
              <div className="flex items-center gap-2 text-danger bg-red-50 px-4 py-2.5 rounded-lg text-sm">
                <AlertTriangle className="size-4 shrink-0" />
                {error}
              </div>
            )}
            <div className="flex justify-end gap-3 pt-2">
              <button
                type="button"
                onClick={closeModal}
                className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
              >
                Annuler
              </button>
              <button
                type="submit"
                disabled={createMutation.isPending || updateMutation.isPending}
                className="px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                {(createMutation.isPending || updateMutation.isPending) && (
                  <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                )}
                {modalMode === 'create' ? 'Créer' : 'Enregistrer'}
              </button>
            </div>
          </form>
        )}
      </Modal>

      <Modal
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Confirmer la suppression"
        size="sm"
      >
        <div className="space-y-4">
          <div className="flex items-center gap-3 text-amber-600 bg-amber-50 px-4 py-3 rounded-lg">
            <AlertTriangle className="size-5 shrink-0" />
            <p className="text-sm">
              Êtes-vous sûr de vouloir supprimer{' '}
              <strong>
                {deleteTarget?.prenom} {deleteTarget?.nom}
              </strong>{' '}
              ?
            </p>
          </div>
          <div className="flex justify-end gap-3">
            <button
              onClick={() => { setDeleteTarget(null); setError(''); }}
              className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              onClick={handleDelete}
              disabled={deleteMutation.isPending}
              className="px-4 py-2 text-sm font-medium text-white bg-danger hover:bg-red-600 rounded-lg transition-colors disabled:opacity-50 flex items-center gap-2"
            >
              {deleteMutation.isPending && (
                <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              )}
              Supprimer
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
