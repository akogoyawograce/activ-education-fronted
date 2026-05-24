import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Search,
  Plus,
  Pencil,
  Trash2,
  AlertTriangle,
  CheckCircle,
  Copy,
} from 'lucide-react'
import * as conseillerService from '@/api/conseillers'
import type { ConseillerResponse } from '@/types'
import UserAvatar from '@/components/ui/UserAvatar'
import Modal from '@/components/ui/Modal'
import PageHeader from '@/components/shared/PageHeader'
import { SkeletonList } from '@/components/ui/Skeleton'

interface ConseillerForm {
  nom: string
  prenom: string
  email: string
  telephone: string
  motDePasse: string
  specialites: string
  biographie: string
  qualifications: string
  anneesExperience: number
}

const emptyForm: ConseillerForm = {
  nom: '',
  prenom: '',
  email: '',
  telephone: '',
  motDePasse: '',
  specialites: '',
  biographie: '',
  qualifications: '',
  anneesExperience: 0,
}

export default function ConseillersPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [modalMode, setModalMode] = useState<'create' | 'edit' | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<ConseillerResponse | null>(null)
  const [editTarget, setEditTarget] = useState<ConseillerResponse | null>(null)
  const [form, setForm] = useState<ConseillerForm>(emptyForm)
  const [error, setError] = useState('')
  const [createdTrackingId, setCreatedTrackingId] = useState('')
  const [copied, setCopied] = useState(false)

  const { data, isLoading } = useQuery({
    queryKey: ['conseillers', page, search],
    queryFn: () => conseillerService.getAll(page - 1, 10),
  })

  const createMutation = useMutation({
    mutationFn: (data: ConseillerForm) =>
      conseillerService.create({
        nom: data.nom,
        prenom: data.prenom,
        email: data.email,
        telephone: data.telephone,
        motDePasse: data.motDePasse || 'default123',
        specialites: data.specialites,
        biographie: data.biographie,
        qualifications: data.qualifications,
        anneesExperience: data.anneesExperience,
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
    mutationFn: ({ id, data }: { id: string; data: ConseillerForm }) =>
      conseillerService.update(id, {
        nom: data.nom,
        prenom: data.prenom,
        email: data.email,
        telephone: data.telephone,
        motDePasse: data.motDePasse || 'default123',
        specialites: data.specialites,
        biographie: data.biographie,
        qualifications: data.qualifications,
        anneesExperience: data.anneesExperience,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['conseillers'] })
      setModalMode(null)
      setForm(emptyForm)
      setError('')
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : 'Erreur lors de la modification')
    },
  })


  const deleteMutation = useMutation({
    mutationFn: (id: string) => conseillerService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['conseillers'] })
      setDeleteTarget(null)
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : 'Erreur lors de la désactivation')
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

  function openEdit(item: ConseillerResponse) {
    setEditTarget(item)
    setForm({
      nom: item.nom,
      prenom: item.prenom,
      email: item.email,
      telephone: item.telephone,
      motDePasse: '',
      specialites: item.specialites,
      biographie: item.biographie,
      qualifications: item.qualifications,
      anneesExperience: item.anneesExperience,
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

  const filtered = data?.content ?? []

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestion des conseillers"
        description={`${data?.totalElements ?? 0} conseillers`}
        actions={
          <button
            onClick={openCreate}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
          >
            <Plus className="size-4" />
            Nouveau conseiller
          </button>
        }
      />

      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
        <input
          type="text"
          placeholder="Rechercher un conseiller..."
          value={search}
          onChange={(e) => {
            setSearch(e.target.value)
            setPage(1)
          }}
          className="w-full pl-10 pr-4 py-2.5 border border-border rounded-lg bg-white text-text-main text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
      </div>

      {isLoading ? (
        <SkeletonList rows={6} />
      ) : filtered.length === 0 ? (
        <div className="bg-card rounded-[12px] border border-border p-12 text-center">
          <p className="text-text-secondary">Aucun conseiller trouvé</p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
            {filtered.map((conseiller) => (
              <div
                key={conseiller.trackingId}
                className="bg-card rounded-[12px] border border-border p-5 flex flex-col gap-4"
              >
                <div className="flex items-center gap-3">
                  <div className="relative">
                    <UserAvatar
                      name={`${conseiller.prenom} ${conseiller.nom}`}
                      size="md"
                      onlineStatus={conseiller.actif}
                    />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="text-sm font-semibold text-text-main truncate">
                      {conseiller.prenom} {conseiller.nom}
                    </h3>
                    <p className="text-xs text-text-secondary truncate">{conseiller.email}</p>
                  </div>
                </div>

                {conseiller.specialites && (
                  <p className="text-sm text-text-secondary line-clamp-2">
                    {conseiller.specialites}
                  </p>
                )}

                <div className="flex flex-wrap gap-1.5">
                  {conseiller.qualifications
                    ?.split(',')
                    .slice(0, 3)
                    .map((q) => (
                      <span
                        key={q.trim()}
                        className="bg-primary-light text-primary text-xs px-2 py-0.5 rounded-full font-medium"
                      >
                        {q.trim()}
                      </span>
                    ))}
                  {conseiller.anneesExperience > 0 && (
                    <span className="bg-secondary-light text-secondary text-xs px-2 py-0.5 rounded-full font-medium">
                      {conseiller.anneesExperience} ans
                    </span>
                  )}
                </div>

                <div className="flex items-center gap-2 pt-1 border-t border-border">
                  <button
                    onClick={() => openEdit(conseiller)}
                    className="flex items-center gap-1.5 text-xs font-medium text-text-secondary hover:text-primary px-2.5 py-1.5 rounded-lg hover:bg-primary-light transition-colors"
                  >
                    <Pencil className="size-3.5" />
                    Modifier
                  </button>
                  <button
                    onClick={() => setDeleteTarget(conseiller)}
                    className="flex items-center gap-1.5 text-xs font-medium text-text-secondary hover:text-danger px-2.5 py-1.5 rounded-lg hover:bg-danger-light transition-colors"
                  >
                    <Trash2 className="size-3.5" />
                    Désactiver
                  </button>
                </div>
              </div>
            ))}
          </div>

          {data && data.totalPages > 1 && (
            <div className="flex items-center justify-between px-4 py-3 bg-card rounded-[12px] border border-border">
              <p className="text-sm text-text-secondary">
                Page {page} / {data.totalPages}
              </p>
              <div className="flex items-center gap-1">
                <button
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page <= 1}
                  className="p-1.5 rounded-lg hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed transition"
                >
                  <svg className="size-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                  </svg>
                </button>
                <button
                  onClick={() => setPage((p) => Math.min(data.totalPages, p + 1))}
                  disabled={page >= data.totalPages}
                  className="p-1.5 rounded-lg hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed transition"
                >
                  <svg className="size-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </button>
              </div>
            </div>
          )}
        </>
      )}

      <Modal
        open={modalMode !== null}
        onClose={closeModal}
        title={modalMode === 'create' ? 'Nouveau conseiller' : 'Modifier le conseiller'}
        size="lg"
      >
        {createdTrackingId ? (
          <div className="space-y-4">
            <div className="flex items-center gap-3 text-green-700 bg-green-50 px-4 py-3 rounded-lg">
              <CheckCircle className="size-5 shrink-0" />
              <p className="text-sm font-medium">
                Conseiller créé avec succès !
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
          {error && (
            <div className="flex items-center gap-2 text-danger bg-red-50 px-4 py-2.5 rounded-lg text-sm">
              <AlertTriangle className="size-4 shrink-0" />
              {error}
            </div>
          )}
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
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Spécialités</label>
            <input
              value={form.specialites}
              onChange={(e) => setForm((f) => ({ ...f, specialites: e.target.value }))}
              placeholder="Ex: Orientation scolaire, Psychologie"
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Biographie</label>
            <textarea
              rows={3}
              value={form.biographie}
              onChange={(e) => setForm((f) => ({ ...f, biographie: e.target.value }))}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">Qualifications</label>
              <input
                value={form.qualifications}
                onChange={(e) => setForm((f) => ({ ...f, qualifications: e.target.value }))}
                placeholder="Ex: Master en psychologie, Certifié"
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-text-main mb-1">
                Années d'expérience
              </label>
              <input
                type="number"
                min={0}
                value={form.anneesExperience}
                onChange={(e) =>
                  setForm((f) => ({ ...f, anneesExperience: parseInt(e.target.value) || 0 }))
                }
                className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
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
              Êtes-vous sûr de vouloir désactiver{' '}
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
              Désactiver
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
