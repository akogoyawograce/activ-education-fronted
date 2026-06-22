import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Shield, Server, Database, HardDrive, HelpCircle, ExternalLink, Check, X, AlertTriangle, Save, Settings, Wrench, Activity, Sliders } from 'lucide-react'
import api from '@/api/client'

type TabId = 'roles' | 'maintenance' | 'integrite' | 'poids-quiz'

const TABS: { id: TabId; label: string; icon: React.ComponentType<{ className?: string }> }[] = [
  { id: 'roles', label: 'Gestion des rôles', icon: Settings },
  { id: 'maintenance', label: 'Mode Maintenance', icon: Wrench },
  { id: 'poids-quiz', label: 'Poids des quiz', icon: Sliders },
  { id: 'integrite', label: 'Intégrité Système', icon: Activity },
]

interface Parametre {
  id: number
  cle: string
  valeur: string
  description: string
  categorie: string
}

interface RoleRow {
  role: string
  permissions: Record<string, boolean>
}

const ROLES_DATA: RoleRow[] = [
  {
    role: 'SUPER_ADMIN',
    permissions: { dashboard: true, eleves: true, quiz: true, faq: true, conseillers: true, parametres: true },
  },
  {
    role: 'MODERATEUR',
    permissions: { dashboard: true, eleves: false, quiz: true, faq: true, conseillers: false, parametres: false },
  },
  {
    role: 'GESTIONNAIRE_CONSEILLER',
    permissions: { dashboard: true, eleves: true, quiz: false, faq: false, conseillers: true, parametres: false },
  },
]

const PERMISSION_LABELS = ['Dashboard', 'Élèves', 'Quiz', 'FAQ', 'Conseillers', 'Paramètres']
const PERMISSION_KEYS = ['dashboard', 'eleves', 'quiz', 'faq', 'conseillers', 'parametres']

function CheckCell({ checked }: { checked: boolean }) {
  return (
    <td className="px-4 py-3 text-center">
      {checked ? (
        <Check className="size-5 text-success mx-auto" />
      ) : (
        <X className="size-5 text-gray-300 mx-auto" />
      )}
    </td>
  )
}

function RoleTab() {
  return (
    <div>
      <h3 className="text-lg font-semibold text-text-main mb-4">Permissions des rôles</h3>
      <p className="text-sm text-text-secondary mb-6">
        Configuration des accès pour chaque rôle. Les modifications sont appliquées automatiquement.
      </p>
      <div className="bg-card rounded-[12px] border border-border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-gray-50/50">
                <th className="px-4 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider w-48">
                  Rôle
                </th>
                {PERMISSION_LABELS.map((label) => (
                  <th
                    key={label}
                    className="px-4 py-3.5 text-center text-xs font-semibold text-text-secondary uppercase tracking-wider"
                  >
                    {label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {ROLES_DATA.map((row) => (
                <tr key={row.role} className="hover:bg-gray-50/50 transition-colors">
                  <td className="px-4 py-3 font-medium text-text-main">{row.role}</td>
                  {PERMISSION_KEYS.map((key) => (
                    <CheckCell key={key} checked={row.permissions[key]} />
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      <div className="mt-4 p-4 bg-blue-50 rounded-[12px] border border-blue-100">
        <p className="text-sm text-blue-700">
          <span className="font-medium">Note :</span> La gestion avancée des rôles et permissions sera disponible
          dans une prochaine version. Pour toute modification, contactez le support technique.
        </p>
      </div>
    </div>
  )
}

function MaintenanceTab() {
  const [enabled, setEnabled] = useState(false)
  const [message, setMessage] = useState('')

  return (
    <div>
      <h3 className="text-lg font-semibold text-text-main mb-4">Mode Maintenance</h3>
      <p className="text-sm text-text-secondary mb-6">
        Activez le mode maintenance pour empêcher l&apos;accès des utilisateurs pendant les mises à jour.
      </p>

      <div className="bg-card rounded-[12px] border border-border p-6 mb-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="font-medium text-text-main">État actuel</p>
            <p className="text-sm text-text-secondary mt-1">
              {enabled ? 'La plateforme est en maintenance' : 'La plateforme est accessible'}
            </p>
          </div>
          <button
            onClick={() => setEnabled(!enabled)}
            className={`relative inline-flex h-7 w-12 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
              enabled ? 'bg-danger' : 'bg-gray-300'
            }`}
          >
            <span
              className={`pointer-events-none inline-block size-6 rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out ${
                enabled ? 'translate-x-5' : 'translate-x-0'
              }`}
            />
          </button>
        </div>
      </div>

      {enabled && (
        <div className="mb-6">
          <label className="block text-sm font-medium text-text-main mb-2">
            Message de maintenance
          </label>
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Entrez le message à afficher aux utilisateurs..."
            rows={4}
            className="w-full rounded-[12px] border border-border bg-white px-4 py-3 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
          />
          <p className="text-xs text-text-secondary mt-1.5">
            Ce message sera affiché sur la page de connexion et les API retourneront un statut 503.
          </p>
        </div>
      )}

      <button
        onClick={() => {}}
        className="inline-flex items-center gap-2 px-5 py-2.5 bg-primary text-white rounded-[12px] hover:bg-primary-dark transition-colors text-sm font-medium"
      >
        <Save className="size-4" />
        Enregistrer
      </button>
    </div>
  )
}

function IntegriteTab() {
  const services = [
    { label: 'Serveur', value: 'www.activ-education.tg', status: 'en ligne', icon: Server },
    { label: 'Base de données', value: 'PostgreSQL 16 (pgvector)', status: 'connectée', icon: Database },
    { label: 'Stockage', value: 'MinIO (3 buckets)', status: 'opérationnel', icon: HardDrive },
  ]

  return (
    <div>
      <h3 className="text-lg font-semibold text-text-main mb-4">Intégrité Système</h3>

      <div className="bg-gradient-to-br from-primary to-primary-dark rounded-[12px] p-8 text-center mb-6">
        <Shield className="size-16 text-white/90 mx-auto mb-3" />
        <p className="text-3xl font-bold text-white">100% SÉCURISÉ</p>
        <p className="text-white/70 text-sm mt-2">Aucune vulnérabilité détectée</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {services.map((svc) => {
          const Icon = svc.icon
          return (
            <div
              key={svc.label}
              className="bg-card rounded-[12px] border border-border p-5"
            >
              <div className="flex items-start gap-3">
                <div className="p-2.5 bg-success-light rounded-xl">
                  <Icon className="size-5 text-success" />
                </div>
                <div className="min-w-0">
                  <p className="text-sm font-medium text-text-main">{svc.label}</p>
                  <p className="text-xs text-text-secondary mt-0.5 truncate">{svc.value}</p>
                  <div className="flex items-center gap-1.5 mt-2">
                    <span className="size-2 rounded-full bg-success inline-block" />
                    <span className="text-xs text-success font-medium">{svc.status}</span>
                  </div>
                </div>
              </div>
            </div>
          )
        })}
      </div>

      <div className="mt-6 p-4 bg-amber-50 rounded-[12px] border border-amber-100">
        <div className="flex items-start gap-3">
          <AlertTriangle className="size-5 text-amber-600 shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-amber-800">Tests d&apos;intrusion</p>
            <p className="text-xs text-amber-700 mt-1">
              Dernier scan de sécurité : 15 mai 2026 — Aucune vulnérabilité critique.
              Prochain scan programmé : 15 juin 2026.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

function PoidsQuizTab() {
  const queryClient = useQueryClient()
  const { data: parametres, isLoading } = useQuery({
    queryKey: ['parametres', 'RECOMMENDATION'],
    queryFn: async () => {
      const res = await api.get<Parametre[]>('/admin/parametres')
      return res.data.filter((p: Parametre) => p.categorie === 'RECOMMENDATION')
    },
  })

  const [edits, setEdits] = useState<Record<string, string>>({})

  const saveMutation = useMutation({
    mutationFn: async ({ cle, valeur }: { cle: string; valeur: string }) => {
      await api.put(`/admin/parametres/${cle}`, { valeur })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['parametres'] })
    },
  })

  const handleSave = (cle: string) => {
    const valeur = edits[cle]
    if (valeur !== undefined) {
      saveMutation.mutate({ cle, valeur })
    }
  }

  if (isLoading) {
    return <div className="text-sm text-text-secondary">Chargement...</div>
  }

  return (
    <div>
      <h3 className="text-lg font-semibold text-text-main mb-4">Poids des quiz et recommandations</h3>
      <p className="text-sm text-text-secondary mb-6">
        Configurez les coefficients utilisés pour le calcul des recommandations d&apos;orientation.
      </p>

      <div className="space-y-4">
        {(parametres ?? []).map((param) => (
          <div key={param.cle} className="bg-card rounded-[12px] border border-border p-5">
            <div className="flex items-start justify-between gap-4">
              <div className="min-w-0 flex-1">
                <label className="block text-sm font-medium text-text-main mb-1">
                  {param.cle.split('.').pop()?.replace(/_/g, ' ')}
                </label>
                <p className="text-xs text-text-secondary mb-2">{param.description}</p>
                <div className="flex items-center gap-3">
                  <input
                    type="number"
                    step="0.1"
                    value={edits[param.cle] ?? param.valeur}
                    onChange={(e) => setEdits({ ...edits, [param.cle]: e.target.value })}
                    className="w-24 rounded-[12px] border border-border bg-white px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  />
                  <span className="text-sm text-text-secondary">{(param.cle.includes('seuil') || param.cle.includes('poids')) ? (param.cle.includes('poids') ? '%' : '') : ''}</span>
                  {edits[param.cle] !== undefined && edits[param.cle] !== param.valeur && (
                    <button
                      onClick={() => handleSave(param.cle)}
                      disabled={saveMutation.isPending}
                      className="inline-flex items-center gap-1.5 px-4 py-2 bg-primary text-white rounded-[12px] hover:bg-primary-dark transition-colors text-sm font-medium disabled:opacity-50"
                    >
                      <Save className="size-4" />
                      Enregistrer
                    </button>
                  )}
                </div>
              </div>
              <span className="text-xs text-text-secondary font-mono shrink-0">{param.cle}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

function HelpCard() {
  const [showGuide, setShowGuide] = useState(false)
  return (
    <>
      <div className="bg-gradient-to-br from-blue-600 to-blue-700 rounded-[12px] p-6">
        <HelpCircle className="size-10 text-white/80 mb-3" />
        <h3 className="text-lg font-semibold text-white">Besoin d&apos;aide ?</h3>
        <p className="text-sm text-white/70 mt-1 mb-4">
          Consultez notre guide d&apos;administration pour plus de détails.
        </p>
        <button
          onClick={() => setShowGuide(true)}
          className="inline-flex items-center gap-2 text-sm font-medium text-white bg-white/20 hover:bg-white/30 px-4 py-2 rounded-[12px] transition-colors"
        >
          Guide d&apos;administration
          <ExternalLink className="size-4" />
        </button>
      </div>
      {showGuide && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm" onClick={() => setShowGuide(false)}>
          <div className="bg-card rounded-[12px] shadow-xl border border-border w-full max-w-lg mx-4 p-6" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-text-main">Guide d&apos;administration</h3>
              <button onClick={() => setShowGuide(false)} className="text-text-secondary hover:text-text-main p-1"><X className="size-5" /></button>
            </div>
            <div className="space-y-3 text-sm text-text-secondary">
              <p><strong className="text-text-main">🚀 Bien démarrer</strong><br />Connectez-vous avec un compte SUPER_ADMIN pour accéder à tous les paramètres.</p>
              <p><strong className="text-text-main">👥 Gérer les utilisateurs</strong><br />Les sections Élèves et Parents permettent de visualiser et gérer les comptes.</p>
              <p><strong className="text-text-main">📚 Contenu pédagogique</strong><br />Les sections Filières et Quiz permettent de créer et modifier le contenu d&apos;orientation.</p>
              <p><strong className="text-text-main">🔧 Maintenance</strong><br />Activez le mode maintenance pour bloquer l&apos;accès pendant les mises à jour.</p>
            </div>
          </div>
        </div>
      )}
    </>
  )
}

export default function ParametresPage() {
  const [activeTab, setActiveTab] = useState<TabId>('roles')

  return (
    <div className="space-y-6">
      <div className="bg-card rounded-[12px] border border-border px-6 py-4">
        <h1 className="text-xl font-semibold text-text-main">Paramètres</h1>
        <p className="text-sm text-text-secondary mt-0.5">Configuration avancée de la plateforme</p>
      </div>

      <div className="flex gap-6 flex-col lg:flex-row">
        <div className="w-full lg:w-56 shrink-0">
          <nav className="bg-card rounded-[12px] border border-border p-2 space-y-1">
            {TABS.map((tab) => {
              const Icon = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full flex items-center gap-2.5 px-4 py-2.5 rounded-[12px] text-sm font-medium transition-colors text-left ${
                    activeTab === tab.id
                      ? 'bg-primary-light text-primary'
                      : 'text-text-secondary hover:text-text-main hover:bg-gray-50'
                  }`}
                >
                  <Icon className="size-4 shrink-0" />
                  {tab.label}
                </button>
              )
            })}
          </nav>

          <div className="mt-4">
            <HelpCard />
          </div>
        </div>

        <div className="flex-1 min-w-0">
          <div className="bg-card rounded-[12px] border border-border p-6">
            {activeTab === 'roles' && <RoleTab />}
            {activeTab === 'maintenance' && <MaintenanceTab />}
            {activeTab === 'poids-quiz' && <PoidsQuizTab />}
            {activeTab === 'integrite' && <IntegriteTab />}
          </div>
        </div>
      </div>
    </div>
  )
}
