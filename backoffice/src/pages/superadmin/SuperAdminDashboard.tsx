import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Users, Shield, BookOpen, MessageSquare, Plus, Pencil, Trash2, AlertTriangle } from 'lucide-react'
import KpiCardGrid from '@/components/shared/KpiCardGrid'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import Modal from '@/components/ui/Modal'
import { SkeletonCard } from '@/components/ui/Skeleton'
import * as administrateurService from '@/api/administrateurs'
import type { AdministrateurResponse, AdministrateurRequest } from '@/types'

const KPI_ITEMS = [
  { title: 'Total Administrateurs', value: 12, trend: 8, trendLabel: 'ce mois', icon: Users, color: 'primary' as const },
  { title: 'Rôles Configurés', value: 3, icon: Shield, color: 'success' as const },
  { title: 'Quiz publiés', value: 24, trend: 12, trendLabel: 'ce trimestre', icon: BookOpen, color: 'secondary' as const },
  { title: 'Messages non lus', value: 7, trend: -15, trendLabel: 'vs hier', icon: MessageSquare, color: 'danger' as const },
]

function AdminForm({
  data,
  onSubmit,
  loading,
}: {
  data?: AdministrateurResponse | null
  onSubmit: (form: AdministrateurRequest) => void
  loading: boolean
}) {
  const [nom, setNom] = useState(data?.nom ?? '')
  const [prenom, setPrenom] = useState(data?.prenom ?? '')
  const [email, setEmail] = useState(data?.email ?? '')
  const [telephone, setTelephone] = useState(data?.telephone ?? '')
  const [motDePasse, setMotDePasse] = useState('')
  const [niveauAcces, setNiveauAcces] = useState(data?.niveauAcces ?? 'ADMIN')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSubmit({
      nom,
      prenom,
      email,
      telephone: telephone || undefined,
      motDePasse: motDePasse || 'changeme123',
      niveauAcces,
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-text-main mb-1">Nom</label>
          <input
            type="text"
            value={nom}
            onChange={(e) => setNom(e.target.value)}
            required
            className="w-full rounded-[12px] border border-border bg-white px-3 py-2.5 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-text-main mb-1">Prénom</label>
          <input
            type="text"
            value={prenom}
            onChange={(e) => setPrenom(e.target.value)}
            required
            className="w-full rounded-[12px] border border-border bg-white px-3 py-2.5 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
      </div>
      <div>
        <label className="block text-sm font-medium text-text-main mb-1">Email</label>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          className="w-full rounded-[12px] border border-border bg-white px-3 py-2.5 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
      </div>
      <div>
        <label className="block text-sm font-medium text-text-main mb-1">Téléphone</label>
        <input
          type="tel"
          value={telephone}
          onChange={(e) => setTelephone(e.target.value)}
          className="w-full rounded-[12px] border border-border bg-white px-3 py-2.5 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
      </div>
      {!data && (
        <div>
          <label className="block text-sm font-medium text-text-main mb-1">Mot de passe</label>
          <input
            type="password"
            value={motDePasse}
            onChange={(e) => setMotDePasse(e.target.value)}
            placeholder="Laissez vide pour un mot de passe par défaut"
            className="w-full rounded-[12px] border border-border bg-white px-3 py-2.5 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
      )}
      <div>
        <label className="block text-sm font-medium text-text-main mb-1">Niveau d&apos;accès</label>
        <select
          value={niveauAcces}
          onChange={(e) => setNiveauAcces(e.target.value)}
          className="w-full rounded-[12px] border border-border bg-white px-3 py-2.5 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        >
          <option value="ADMIN">Administrateur</option>
          <option value="SUPER_ADMIN">Super Admin</option>
          <option value="MODERATEUR">Modérateur</option>
          <option value="GESTIONNAIRE_CONSEILLER">Gestionnaire Conseiller</option>
        </select>
      </div>
      <div className="flex justify-end gap-3 pt-2">
        <button
          type="submit"
          disabled={loading}
          className="px-5 py-2.5 bg-primary text-white rounded-[12px] hover:bg-primary-dark transition-colors text-sm font-medium disabled:opacity-50"
        >
          {loading ? 'Enregistrement...' : data ? 'Mettre à jour' : 'Créer'}
        </button>
      </div>
    </form>
  )
}

export default function SuperAdminDashboard() {
  const queryClient = useQueryClient()
  const [modalOpen, setModalOpen] = useState(false)
  const [editAdmin, setEditAdmin] = useState<AdministrateurResponse | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<AdministrateurResponse | null>(null)

  const { data: adminsPage, isLoading } = useQuery({
    queryKey: ['administrateurs', 0],
    queryFn: () => administrateurService.getAll(0, 100),
  })

  const createMutation = useMutation({
    mutationFn: (data: AdministrateurRequest) => administrateurService.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['administrateurs'] })
      setModalOpen(false)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: AdministrateurRequest }) =>
      administrateurService.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['administrateurs'] })
      setEditAdmin(null)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => administrateurService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['administrateurs'] })
      setDeleteTarget(null)
    },
  })

  const admins = adminsPage?.content ?? []

  const columns = [
    { key: 'nom', label: 'Nom' },
    { key: 'prenom', label: 'Prénom' },
    { key: 'email', label: 'Email' },
    {
      key: 'niveauAcces',
      label: "Niveau d'accès",
      render: (item: AdministrateurResponse) => <StatusBadge status={item.niveauAcces} />,
    },
    {
      key: 'actif',
      label: 'Statut',
      render: (item: AdministrateurResponse) => (
        <span
          className={`inline-flex items-center gap-1.5 text-sm font-medium ${
            item.actif ? 'text-success' : 'text-danger'
          }`}
        >
          <span className={`size-2 rounded-full ${item.actif ? 'bg-success' : 'bg-danger'}`} />
          {item.actif ? 'Actif' : 'Inactif'}
        </span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: AdministrateurResponse) => (
        <div className="flex items-center gap-1">
          <button
            onClick={(e) => {
              e.stopPropagation()
              setEditAdmin(item)
            }}
            className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors text-text-secondary hover:text-primary"
            title="Modifier"
          >
            <Pencil className="size-4" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation()
              setDeleteTarget(item)
            }}
            className="p-1.5 rounded-lg hover:bg-red-50 transition-colors text-text-secondary hover:text-danger"
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
      <div className="bg-card rounded-[12px] border border-border px-6 py-4">
        <h1 className="text-xl font-semibold text-text-main">Tableau de bord Super Admin</h1>
        <p className="text-sm text-text-secondary mt-0.5">Vue d&apos;ensemble de la plateforme</p>
      </div>

      <KpiCardGrid items={KPI_ITEMS} />

      <div className="bg-card rounded-[12px] border border-border p-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-lg font-semibold text-text-main">Gestion des Administrateurs</h2>
            <p className="text-sm text-text-secondary mt-0.5">
              {admins.length > 0
                ? `${admins.length} administrateur${admins.length > 1 ? 's' : ''} enregistré${admins.length > 1 ? 's' : ''}`
                : 'Gérez les comptes administrateurs'}
            </p>
          </div>
          <button
            onClick={() => setModalOpen(true)}
            className="inline-flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-[12px] hover:bg-primary-dark transition-colors text-sm font-medium"
          >
            <Plus className="size-4" />
            Nouvel administrateur
          </button>
        </div>

        {isLoading ? (
          <div className="space-y-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        ) : (
          <DataTable
            columns={columns}
            data={admins}
          />
        )}
      </div>

      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title="Nouvel administrateur"
        size="lg"
      >
        <AdminForm
          onSubmit={(data) => createMutation.mutate(data)}
          loading={createMutation.isPending}
        />
      </Modal>

      <Modal
        open={!!editAdmin}
        onClose={() => setEditAdmin(null)}
        title="Modifier l'administrateur"
        size="lg"
      >
        <AdminForm
          data={editAdmin}
          onSubmit={(data) => {
            if (editAdmin) updateMutation.mutate({ id: editAdmin.trackingId, data })
          }}
          loading={updateMutation.isPending}
        />
      </Modal>

      <Modal
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Confirmer la suppression"
        size="sm"
      >
        <div className="space-y-4">
          <div className="flex items-start gap-3">
            <div className="p-2 bg-danger-light rounded-xl shrink-0">
              <AlertTriangle className="size-5 text-danger" />
            </div>
            <div>
              <p className="text-sm text-text-main">
                Êtes-vous sûr de vouloir supprimer{' '}
                <span className="font-semibold">
                  {deleteTarget?.prenom} {deleteTarget?.nom}
                </span>{' '}
                ? Cette action est irréversible.
              </p>
            </div>
          </div>
          <div className="flex justify-end gap-3">
            <button
              onClick={() => setDeleteTarget(null)}
              className="px-4 py-2 border border-border rounded-[12px] text-sm font-medium text-text-secondary hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              onClick={() => {
                if (deleteTarget) {
                  deleteMutation.mutate(deleteTarget.trackingId)
                }
              }}
              disabled={deleteMutation.isPending}
              className="px-4 py-2 bg-danger text-white rounded-[12px] hover:bg-red-600 transition-colors text-sm font-medium disabled:opacity-50"
            >
              {deleteMutation.isPending ? 'Suppression...' : 'Supprimer'}
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
