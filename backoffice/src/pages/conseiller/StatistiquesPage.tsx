import { useQuery } from '@tanstack/react-query'
import { Users, Briefcase, ClipboardList, TrendingUp } from 'lucide-react'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts'
import * as statsService from '@/api/stats'
import * as rendezvousService from '@/api/rendezvous'
import type { RendezVousResponse } from '@/types'
import { useAuthStore } from '@/stores/authStore'
import PageHeader from '@/components/shared/PageHeader'
import StatCard from '@/components/ui/StatCard'
import StatusBadge from '@/components/ui/StatusBadge'
import { SkeletonCard } from '@/components/ui/Skeleton'
import { format, parseISO } from 'date-fns'
import { fr } from 'date-fns/locale'

export default function StatistiquesPage() {
  const trackingId = useAuthStore((s) => s.trackingId)

  const { data: kpis, isLoading: loadingKpis } = useQuery({
    queryKey: ['stats-kpis'],
    queryFn: () => statsService.getKPIs(),
  })

  const { data: rendezVous, isLoading: loadingRdvs } = useQuery({
    queryKey: ['rendezvous', trackingId],
    queryFn: () => rendezvousService.getByConseiller(trackingId!),
    enabled: !!trackingId,
  })

  const monthlyData = (rendezVous ?? []).reduce(
    (acc, rdv) => {
      const month = format(parseISO(rdv.dateHeurePrevue), 'MMM', { locale: fr })
      const existing = acc.find((a) => a.month === month)
      if (existing) {
        existing.total++
        if (rdv.statut === 'TERMINE') existing.termine++
      } else {
        acc.push({ month, total: 1, termine: rdv.statut === 'TERMINE' ? 1 : 0 })
      }
      return acc
    },
    [] as { month: string; total: number; termine: number }[],
  )

  const recentRdvs = (rendezVous ?? [])
    .sort((a, b) => new Date(b.dateHeurePrevue).getTime() - new Date(a.dateHeurePrevue).getTime())
    .slice(0, 5)

  const totalRdvs = rendezVous?.length ?? 0
  const termines = rendezVous?.filter((r: RendezVousResponse) => r.statut === 'TERMINE').length ?? 0
  const tauxCompletion = totalRdvs > 0 ? Math.round((termines / totalRdvs) * 100) : 0

  if (loadingKpis || loadingRdvs) {
    return (
      <div className="space-y-6">
        <PageHeader title="Statistiques" description="Suivez votre activité" />
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => <SkeletonCard key={i} />)}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <SkeletonCard />
          <SkeletonCard />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Statistiques" description="Suivez votre activité et vos performances" />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total élèves"
          value={kpis?.totalEleves ?? 0}
          icon={Users}
          color="primary"
          trend={8}
          trendLabel="ce mois"
        />
        <StatCard
          title="Total rendez-vous"
          value={totalRdvs}
          icon={Briefcase}
          color="secondary"
          trend={totalRdvs > 0 ? 15 : 0}
          trendLabel="total"
        />
        <StatCard
          title="Taux de complétion"
          value={`${tauxCompletion}%`}
          icon={ClipboardList}
          color="success"
          trend={tauxCompletion > 50 ? 5 : -3}
          trendLabel="vs mois dernier"
        />
        <StatCard
          title="Conseillers actifs"
          value={kpis?.totalConseillers ?? 0}
          icon={TrendingUp}
          color="blue"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-card rounded-[12px] border border-border p-5">
          <h2 className="text-base font-semibold text-text-main mb-4">Rendez-vous mensuels</h2>
          {monthlyData.length === 0 ? (
            <p className="text-text-secondary text-sm py-8 text-center">Aucune donnée disponible</p>
          ) : (
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={monthlyData} barCategoryGap="20%">
                  <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                  <XAxis dataKey="month" tick={{ fontSize: 12, fill: '#6B7280' }} />
                  <YAxis tick={{ fontSize: 12, fill: '#6B7280' }} allowDecimals={false} />
                  <Tooltip
                    contentStyle={{
                      borderRadius: 8,
                      border: '1px solid #E5E7EB',
                      fontSize: 13,
                    }}
                  />
                  <Bar dataKey="total" name="Total" fill="#3730E8" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="termine" name="Terminés" fill="#10B981" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        <div className="bg-card rounded-[12px] border border-border p-5">
          <h2 className="text-base font-semibold text-text-main mb-4">Activité récente</h2>
          {recentRdvs.length === 0 ? (
            <p className="text-text-secondary text-sm py-8 text-center">Aucune activité récente</p>
          ) : (
            <div className="space-y-3">
              {recentRdvs.map((rdv: RendezVousResponse) => (
                <div
                  key={rdv.trackingId}
                  className="flex items-center justify-between p-3 rounded-lg bg-gray-50"
                >
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-text-main truncate">
                      Rendez-vous avec {rdv.eleveTrackingId}
                    </p>
                    <p className="text-xs text-text-secondary mt-0.5">
                      {format(parseISO(rdv.dateHeurePrevue), 'dd MMM yyyy HH:mm', { locale: fr })}
                    </p>
                  </div>
                  <StatusBadge status={rdv.statut} />
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
