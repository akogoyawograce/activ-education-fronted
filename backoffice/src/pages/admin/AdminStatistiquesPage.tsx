import { useQuery } from '@tanstack/react-query'
import {
  Users,
  Briefcase,
  FileQuestion,
  GraduationCap,
} from 'lucide-react'
import {
  LineChart,
  Line,
  BarChart,
  Bar,
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

const tooltipStyle = {
  borderRadius: 12,
  border: '1px solid #E5E7EB',
  backgroundColor: '#FFFFFF',
}

const COLORS = ['#3730E8', '#F59E0B', '#10B981', '#EF4444', '#8B5CF6', '#EC4899']

export default function AdminStatistiquesPage() {
  const { data: kpis } = useQuery({
    queryKey: ['admin-stats-kpis'],
    queryFn: () => statsService.getKPIs(),
  })

  const { data: inscriptions } = useQuery({
    queryKey: ['admin-stats-inscriptions'],
    queryFn: () => statsService.getInscriptions(30),
  })

  const { data: quizCompletes } = useQuery({
    queryKey: ['admin-stats-quiz-completes'],
    queryFn: () => statsService.getQuizCompletes(30),
  })

  const { data: rdvData } = useQuery({
    queryKey: ['admin-stats-rdv'],
    queryFn: () => statsService.getRDV(12),
  })

  const { data: quizDomaine } = useQuery({
    queryKey: ['admin-stats-quiz-domaine'],
    queryFn: () => statsService.getQuizParDomaine(),
  })

  const kpiItems = [
    {
      title: 'Total Élèves',
      value: kpis?.totalEleves ?? 0,
      icon: GraduationCap,
      color: 'primary' as const,
    },
    {
      title: 'Conseillers',
      value: kpis?.totalConseillers ?? 0,
      icon: Briefcase,
      color: 'secondary' as const,
    },
    {
      title: 'Quiz',
      value: kpis?.totalQuiz ?? 0,
      icon: FileQuestion,
      color: 'success' as const,
    },
    {
      title: 'Quiz complétés',
      value: kpis?.totalResultats ?? 0,
      icon: Users,
      color: 'blue' as const,
    },
  ]

  const mergedActivity = (inscriptions ?? []).map((ins, i) => {
    const quiz = quizCompletes?.[i]
    return {
      jour: ins.date?.slice(5) ?? '',
      inscrits: ins.count,
      quiz: quiz?.count ?? 0,
    }
  })

  const domaineData = quizDomaine
    ? Object.entries(quizDomaine).map(([name, value]) => ({ name, value }))
    : []

  const monthLabels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc']

  const rdvChartData = (rdvData ?? []).map((r) => {
    const parts = r.mois.split('-')
    const m = monthLabels[parseInt(parts[1]) - 1] ?? parts[1]
    return { mois: `${m} ${parts[0]}`, rdv: r.count }
  })

  return (
    <div className="space-y-6">
      <PageHeader
        title="Statistiques"
        description="Indicateurs clés de la plateforme"
      />

      <KpiCardGrid items={kpiItems} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-4">
            Inscriptions et quiz complétés (30 jours)
          </h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={mergedActivity}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="jour" stroke="#6B7280" fontSize={12} />
                <YAxis stroke="#6B7280" fontSize={12} />
                <Tooltip contentStyle={tooltipStyle} />
                <Line
                  type="monotone"
                  dataKey="inscrits"
                  stroke="#10B981"
                  strokeWidth={2}
                  dot={{ fill: '#10B981', r: 3 }}
                  name="Inscriptions"
                />
                <Line
                  type="monotone"
                  dataKey="quiz"
                  stroke="#F59E0B"
                  strokeWidth={2}
                  dot={{ fill: '#F59E0B', r: 3 }}
                  name="Quiz complétés"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-4">
            Rendez-vous par mois
          </h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={rdvChartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="mois" stroke="#6B7280" fontSize={12} />
                <YAxis stroke="#6B7280" fontSize={12} />
                <Tooltip contentStyle={tooltipStyle} />
                <Bar
                  dataKey="rdv"
                  fill="#3730E8"
                  radius={[4, 4, 0, 0]}
                  name="RDV"
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-4">
            Quiz par domaine
          </h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={domaineData}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={80}
                  paddingAngle={4}
                  dataKey="value"
                  nameKey="name"
                >
                  {domaineData.map((_, index) => (
                    <Cell key={index} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={tooltipStyle} />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-col gap-2 mt-2">
            {domaineData.map((item, i) => (
              <div key={item.name} className="flex items-center justify-between text-sm">
                <span className="flex items-center gap-2">
                  <span
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: COLORS[i % COLORS.length] }}
                  />
                  {item.name}
                </span>
                <span className="font-medium text-text-main">{item.value}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="lg:col-span-2 bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-2">
            Résumé de la plateforme
          </h3>
          <p className="text-sm text-text-secondary mb-4">
            Aperçu des indicateurs clés actuels
          </p>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-gray-50 rounded-lg p-4 text-center">
              <p className="text-2xl font-bold text-primary">{kpis?.totalEleves ?? '-'}</p>
              <p className="text-xs text-text-secondary mt-1">Élèves</p>
            </div>
            <div className="bg-gray-50 rounded-lg p-4 text-center">
              <p className="text-2xl font-bold text-secondary">{kpis?.totalConseillers ?? '-'}</p>
              <p className="text-xs text-text-secondary mt-1">Conseillers</p>
            </div>
            <div className="bg-gray-50 rounded-lg p-4 text-center">
              <p className="text-2xl font-bold text-success">{kpis?.totalQuiz ?? '-'}</p>
              <p className="text-xs text-text-secondary mt-1">Quiz</p>
            </div>
            <div className="bg-gray-50 rounded-lg p-4 text-center">
              <p className="text-2xl font-bold text-danger">{kpis?.totalResultats ?? '-'}</p>
              <p className="text-xs text-text-secondary mt-1">Quiz complétés</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
