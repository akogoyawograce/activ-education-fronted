import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import PageHeader from '@/components/shared/PageHeader'
import DataTable from '@/components/ui/DataTable'
import StatusBadge from '@/components/ui/StatusBadge'
import { SkeletonCard } from '@/components/ui/Skeleton'
import { Search, Download, FileText, Trash2, Activity } from 'lucide-react'
import * as logsService from '@/api/logs'
import type { AuditLogEntry } from '@/api/logs'

const ACTIONS = ['CONNEXION', 'MODIFICATION', 'SUPPRESSION', 'CREATION', 'CONSULTATION', 'EXPORT', 'TENTATIVE_ECHEC']

export default function LogsPage() {
  const [fromDate, setFromDate] = useState('')
  const [toDate, setToDate] = useState('')
  const [userSearch, setUserSearch] = useState('')
  const [actionFilter, setActionFilter] = useState('')
  const [page, setPage] = useState(0)
  const pageSize = 8

  const { data: logsPage, isLoading } = useQuery({
    queryKey: ['audit-logs', page, userSearch, actionFilter, fromDate, toDate],
    queryFn: () => logsService.getLogs({
      email: userSearch || undefined,
      action: actionFilter || undefined,
      fromDate: fromDate ? new Date(fromDate).toISOString() : undefined,
      toDate: toDate ? new Date(toDate + 'T23:59:59').toISOString() : undefined,
      page,
      size: pageSize,
    }),
  })

  const logs = logsPage?.content ?? []
  const totalPages = logsPage?.totalPages ?? 1

  const columns = [
    {
      key: 'createdAt',
      label: 'Horodatage',
      render: (item: AuditLogEntry) => (
        <span className="text-sm text-text-secondary font-mono">
          {item.createdAt?.replace('T', ' ').slice(0, 19) ?? '-'}
        </span>
      ),
    },
    {
      key: 'utilisateurEmail',
      label: 'Utilisateur',
      render: (item: AuditLogEntry) => (
        <span>{item.utilisateurEmail ?? item.utilisateurNom ?? '-'}</span>
      ),
    },
    {
      key: 'action',
      label: 'Action',
    },
    {
      key: 'ressource',
      label: 'Ressource',
      render: (item: AuditLogEntry) => (
        <span className="text-xs font-mono text-text-secondary">{item.ressource ?? '-'}</span>
      ),
    },
    {
      key: 'action',
      label: 'Niveau',
      render: (item: AuditLogEntry) => {
        const level = item.action === 'TENTATIVE_ECHEC' ? 'ERREUR'
          : item.action === 'SUPPRESSION' ? 'AVERTISSEMENT'
          : 'INFO'
        return <StatusBadge status={level} />
      },
    },
    {
      key: 'ip',
      label: 'IP',
      render: (item: AuditLogEntry) => (
        <span className="text-sm text-text-secondary font-mono">{item.ip ?? '-'}</span>
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
              onChange={(e) => { setFromDate(e.target.value); setPage(0) }}
              className="rounded-[12px] border border-border bg-white px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="min-w-0">
            <label className="block text-xs font-medium text-text-secondary mb-1">Au</label>
            <input
              type="date"
              value={toDate}
              onChange={(e) => { setToDate(e.target.value); setPage(0) }}
              className="rounded-[12px] border border-border bg-white px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div className="min-w-0 flex-1 max-w-xs">
            <label className="block text-xs font-medium text-text-secondary mb-1">Email</label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
              <input
                type="text"
                placeholder="Rechercher..."
                value={userSearch}
                onChange={(e) => { setUserSearch(e.target.value); setPage(0) }}
                className="w-full rounded-[12px] border border-border bg-white pl-9 pr-3 py-2 text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              />
            </div>
          </div>
          <div className="min-w-0">
            <label className="block text-xs font-medium text-text-secondary mb-1">Type d&apos;action</label>
            <select
              value={actionFilter}
              onChange={(e) => { setActionFilter(e.target.value); setPage(0) }}
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

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => <SkeletonCard key={i} />)}
        </div>
      ) : (
        <DataTable
          columns={columns}
          data={logs}
          pagination={{
            page: page + 1,
            totalPages,
            onPageChange: (p) => setPage(p - 1),
          }}
        />
      )}

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
            {logsPage ? `${logsPage.totalElements} entrées` : 'Serveur connecté'}
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
