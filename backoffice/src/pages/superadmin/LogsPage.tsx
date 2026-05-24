import { useState, useMemo } from 'react'
import PageHeader from '@/components/shared/PageHeader'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import { Search, Download, FileText, Trash2, Activity } from 'lucide-react'

type LogLevel = 'INFO' | 'AVERTISSEMENT' | 'ERREUR'

interface LogEntry {
  id: string
  horodatage: string
  utilisateur: string
  action: string
  ressource: string
  niveau: LogLevel
  ip: string
}

const ACTIONS = ['CONNEXION', 'MODIFICATION', 'SUPPRESSION', 'CRÉATION', 'CONSULTATION', 'EXPORT', 'TENTATIVE_ECHEC']
const USERS = ['admin@activ-education.tg', 'moderateur@activ-education.tg', 'superadmin@activ-education.tg', 'gestionnaire@activ-education.tg', 'system@activ-education.tg']
const RESSOURCES = ['/api/v1/eleves', '/api/v1/quiz', '/api/v1/administrateurs', '/api/v1/parametres', '/api/v1/conseillers', '/api/v1/faq', '/api/v1/logs', '/api/v1/seuils']
const IPS = ['192.168.1.42', '10.0.0.15', '172.16.0.8', '192.168.1.100', '10.0.0.1', '192.168.1.77', '172.16.0.23']

function randomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)]
}

function generateLogs(): LogEntry[] {
  const logs: LogEntry[] = []
  const now = Date.now()
  const levels: LogLevel[] = ['INFO', 'AVERTISSEMENT', 'ERREUR']

  for (let i = 0; i < 20; i++) {
    const date = new Date(now - i * 3600000 * (Math.random() * 4 + 0.5))
    const niveau = i < 2 ? 'ERREUR' : i < 5 ? 'AVERTISSEMENT' : randomItem(levels)
    logs.push({
      id: `log-${i + 1}`,
      horodatage: date.toISOString().replace('T', ' ').slice(0, 19),
      utilisateur: randomItem(USERS),
      action: randomItem(ACTIONS),
      ressource: randomItem(RESSOURCES),
      niveau,
      ip: randomItem(IPS),
    })
  }

  return logs.sort((a, b) => b.horodatage.localeCompare(a.horodatage))
}

const MOCK_LOGS = generateLogs()

export default function LogsPage() {
  const [fromDate, setFromDate] = useState('')
  const [toDate, setToDate] = useState('')
  const [userSearch, setUserSearch] = useState('')
  const [actionFilter, setActionFilter] = useState('')
  const [page, setPage] = useState(1)
  const pageSize = 8

  const filteredLogs = useMemo(() => {
    return MOCK_LOGS.filter((log) => {
      if (fromDate && log.horodatage < fromDate) return false
      if (toDate && log.horodatage > toDate + 'T23:59:59') return false
      if (userSearch && !log.utilisateur.toLowerCase().includes(userSearch.toLowerCase())) return false
      if (actionFilter && log.action !== actionFilter) return false
      return true
    })
  }, [fromDate, toDate, userSearch, actionFilter])

  const totalPages = Math.max(1, Math.ceil(filteredLogs.length / pageSize))
  const paginatedLogs = filteredLogs.slice((page - 1) * pageSize, page * pageSize)

  const columns = [
    {
      key: 'horodatage',
      label: 'Horodatage',
      render: (item: LogEntry) => (
        <span className="text-sm text-text-secondary font-mono">{item.horodatage}</span>
      ),
    },
    {
      key: 'utilisateur',
      label: 'Utilisateur',
    },
    {
      key: 'action',
      label: 'Action',
    },
    {
      key: 'ressource',
      label: 'Ressource',
      render: (item: LogEntry) => (
        <span className="text-xs font-mono text-text-secondary">{item.ressource}</span>
      ),
    },
    {
      key: 'niveau',
      label: 'Niveau',
      render: (item: LogEntry) => <StatusBadge status={item.niveau} />,
    },
    {
      key: 'ip',
      label: 'IP',
      render: (item: LogEntry) => (
        <span className="text-sm text-text-secondary font-mono">{item.ip}</span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader title="Journaux d'Audit" description="Suivi des activités et événements système" />

      <div className="bg-card rounded-[12px] border border-border p-4">
        <div className="flex flex-wrap items-end gap-3">
          <div className="min-w-0">
            <label className="block text-xs font-medium text-text-secondary mb-1">Du</label>
            <input
              type="date"
              value={fromDate}
              onChange={(e) => { setFromDate(e.target.value); setPage(1) }}
              className="rounded-[12px] border border-border bg-white px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="min-w-0">
            <label className="block text-xs font-medium text-text-secondary mb-1">Au</label>
            <input
              type="date"
              value={toDate}
              onChange={(e) => { setToDate(e.target.value); setPage(1) }}
              className="rounded-[12px] border border-border bg-white px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="min-w-0 flex-1 max-w-xs">
            <label className="block text-xs font-medium text-text-secondary mb-1">Utilisateur</label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
              <input
                type="text"
                placeholder="Rechercher..."
                value={userSearch}
                onChange={(e) => { setUserSearch(e.target.value); setPage(1) }}
                className="w-full rounded-[12px] border border-border bg-white pl-9 pr-3 py-2 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="min-w-0">
            <label className="block text-xs font-medium text-text-secondary mb-1">Type d&apos;action</label>
            <select
              value={actionFilter}
              onChange={(e) => { setActionFilter(e.target.value); setPage(1) }}
              className="rounded-[12px] border border-border bg-white px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            >
              <option value="">Toutes</option>
              {ACTIONS.map((a) => (
                <option key={a} value={a}>{a}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={paginatedLogs}
        pagination={{
          page,
          totalPages,
          onPageChange: setPage,
        }}
      />

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-gradient-to-br from-blue-600 to-blue-700 rounded-[12px] p-5">
          <div className="flex items-center gap-3 mb-3">
            <div className="p-2 bg-white/20 rounded-xl">
              <FileText className="size-5 text-white" />
            </div>
            <p className="text-sm font-medium text-white/80">Rapport PDF Hebdomadaire</p>
          </div>
          <button className="w-full text-sm font-medium text-blue-700 bg-white hover:bg-white/90 px-4 py-2 rounded-[12px] transition-colors">
            Télécharger
          </button>
        </div>

        <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-[12px] p-5">
          <div className="flex items-center gap-3 mb-3">
            <div className="p-2 bg-white/20 rounded-xl">
              <Download className="size-5 text-white" />
            </div>
            <p className="text-sm font-medium text-white/80">Export CSV (Raw Data)</p>
          </div>
          <button className="w-full text-sm font-medium text-orange-600 bg-white hover:bg-white/90 px-4 py-2 rounded-[12px] transition-colors">
            Exporter
          </button>
        </div>

        <div className="bg-card rounded-[12px] border border-border p-5">
          <div className="flex items-center gap-3 mb-3">
            <div className="p-2 bg-gray-100 rounded-xl">
              <Trash2 className="size-5 text-gray-600" />
            </div>
            <p className="text-sm font-medium text-text-main">Nettoyage Automatique</p>
          </div>
          <p className="text-xs text-text-secondary mb-3">Supprime les logs de plus de 90 jours</p>
          <button className="w-full text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 px-4 py-2 rounded-[12px] transition-colors">
            Nettoyer
          </button>
        </div>
      </div>

      <div className="bg-card rounded-[12px] border border-border px-6 py-3 flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center gap-2">
          <span className="size-2.5 rounded-full bg-success inline-block animate-pulse" />
          <span className="text-sm text-text-secondary">
            Serveur Temps Réel : <span className="text-success font-medium">OK</span>
          </span>
        </div>
        <div className="flex items-center gap-1 text-sm text-text-secondary">
          <Activity className="size-4" />
          Version Système : 1.0.0
        </div>
      </div>
    </div>
  )
}
