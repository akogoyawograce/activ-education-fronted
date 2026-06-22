import { useQuery } from '@tanstack/react-query'
import {
  Users,
  Briefcase,
  FileQuestion,
  BookOpen,
  GraduationCap,
} from 'lucide-react'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts'
import * as statsService from '@/api/stats'
import KpiCardGrid from '@/components/shared/KpiCardGrid'
import PageHeader from '@/components/shared/PageHeader'
import { SkeletonCard } from '@/components/ui/Skeleton'

const TYPE_APPRENANT_LABELS: Record<string, string> = {
  ECOLIER: 'Écolier',
  COLLEGIEN: 'Collégien',
  LYCEEN: 'Lycéen',
  ETUDIANT: 'Étudiant',
  PROFESSIONNEL: 'Professionnel',
  AUTRE: 'Autre',
}

const TYPE_APPRENANT_COLORS: Record<string, string> = {
  ECOLIER: '#8B5CF6',
  COLLEGIEN: '#3730E8',
  LYCEEN: '#F59E0B',
  ETUDIANT: '#10B981',
  PROFESSIONNEL: '#EF4444',
  AUTRE: '#6B7280',
}

export default function AdminDashboard() {
  const { data: kpi, isLoading: loadingKpi } = useQuery({
    queryKey: ['admin-dashboard', 'kpi'],
    queryFn: () => statsService.getKPIs(),
  })
  const { data: inscriptions } = useQuery({
    queryKey: ['admin-dashboard', 'inscriptions'],
    queryFn: () => statsService.getInscriptions(7),
  })
  const { data: quizCompletes } = useQuery({
    queryKey: ['admin-dashboard', 'quiz-completes'],
    queryFn: () => statsService.getQuizCompletes(7),
  })
  const { data: typeApprenant, isLoading: loadingType } = useQuery({
    queryKey: ['admin-dashboard', 'type-apprenant'],
    queryFn: () => statsService.getTypeApprenant(),
  })
  const { data: fichesRecentes, isLoading: loadingFiches } = useQuery({
    queryKey: ['admin-dashboard', 'fiches-recentes'],
    queryFn: () => statsService.getFichesRecentes(5),
  })
  const isLoading = loadingKpi || loadingType || loadingFiches

  const activityChartData = (inscriptions ?? []).map((insc, i) => {
    const quiz = quizCompletes?.[i]
    const dayNames = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
    const date = new Date(insc.date)
    return {
      jour: dayNames[date.getDay()] || insc.date.slice(5),
      inscriptions: insc.count,
      quiz: quiz?.count ?? 0,
    }
  }).slice(-7)

  const typeEntries = Object.entries(typeApprenant ?? {})
  const totalType = typeEntries.reduce((s, [, v]) => s + v, 0)
  const profileChart = typeEntries.map(([key, value]) => ({
    name: TYPE_APPRENANT_LABELS[key] ?? key,
    value,
    color: TYPE_APPRENANT_COLORS[key] ?? '#6B7280',
  }))

  const kpiItems = [
    {
      title: 'Total Élèves',
      value: kpi?.totalEleves ?? 0,
      icon: GraduationCap,
      color: 'primary' as const,
    },
    {
      title: 'Total Parents',
      value: kpi?.totalEleves ?? 0,
      icon: Users,
      color: 'blue' as const,
    },
    {
      title: 'Conseillers',
      value: kpi?.totalConseillers ?? 0,
      icon: Briefcase,
      color: 'secondary' as const,
    },
    {
      title: 'Quiz',
      value: kpi?.totalQuiz ?? 0,
      icon: FileQuestion,
      color: 'success' as const,
    },
    {
      title: 'Fiches',
      value: kpi?.totalFiches ?? 0,
      icon: BookOpen,
      color: 'primary' as const,
    },
  ]

  if (isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader title="Tableau de bord" description="Vue d'ensemble de la plateforme" />
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <SkeletonCard key={i} />
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Tableau de bord" description="Vue d'ensemble de la plateforme" />

      <KpiCardGrid items={kpiItems} />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-4">Activité (7 derniers jours)</h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={activityChartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="jour" stroke="#6B7280" fontSize={12} />
                <YAxis stroke="#6B7280" fontSize={12} />
                <Tooltip
                  contentStyle={{
                    borderRadius: 12,
                    border: '1px solid #E5E7EB',
                    backgroundColor: '#FFFFFF',
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="inscriptions"
                  stroke="#3730E8"
                  strokeWidth={2}
                  dot={{ fill: '#3730E8', r: 4 }}
                  name="Inscriptions"
                />
                <Line
                  type="monotone"
                  dataKey="quiz"
                  stroke="#10B981"
                  strokeWidth={2}
                  dot={{ fill: '#10B981', r: 4 }}
                  name="Quiz complétés"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-4">Répartition des profils</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={profileChart}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={80}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {profileChart.map((entry) => (
                    <Cell key={entry.name} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    borderRadius: 12,
                    border: '1px solid #E5E7EB',
                    backgroundColor: '#FFFFFF',
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-col gap-2 mt-2">
            {profileChart.map((item) => (
              <div key={item.name} className="flex items-center justify-between text-sm">
                <span className="flex items-center gap-2">
                  <span
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: item.color }}
                  />
                  {item.name}
                </span>
                <span className="font-medium text-text-main">
                  {totalType > 0 ? Math.round(item.value / totalType * 100) : 0}%
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-card rounded-[12px] border border-border p-5">
        <h3 className="text-base font-semibold text-text-main mb-4">Dernières fiches modifiées</h3>
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border">
              <th className="px-4 py-3 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                Titre
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                Type
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                Modifiée le
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">
                Statut
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {(fichesRecentes ?? []).length === 0 ? (
              <tr>
                <td colSpan={4} className="px-4 py-8 text-center text-text-secondary">
                  Aucune fiche modifiée récemment
                </td>
              </tr>
            ) : (
              (fichesRecentes ?? []).map((fiche, idx) => (
                <tr key={fiche.trackingId ?? idx}>
                  <td className="px-4 py-3 font-medium text-text-main">{fiche.titre}</td>
                  <td className="px-4 py-3 text-text-secondary">{fiche.type}</td>
                  <td className="px-4 py-3 text-text-secondary">
                    {fiche.modifieeLe ? fiche.modifieeLe.slice(0, 10) : '-'}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        fiche.estPublie
                          ? 'bg-success-light text-success'
                          : 'bg-gray-100 text-gray-600'
                      }`}
                    >
                      {fiche.estPublie ? 'Publié' : 'Brouillon'}
                    </span>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
