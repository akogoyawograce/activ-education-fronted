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

const dailyActivity = [
  { jour: 'Lun', visites: 120, inscrits: 18, quiz: 45 },
  { jour: 'Mar', visites: 95, inscrits: 12, quiz: 38 },
  { jour: 'Mer', visites: 150, inscrits: 24, quiz: 62 },
  { jour: 'Jeu', visites: 110, inscrits: 15, quiz: 51 },
  { jour: 'Ven', visites: 80, inscrits: 10, quiz: 33 },
  { jour: 'Sam', visites: 45, inscrits: 5, quiz: 20 },
  { jour: 'Dim', visites: 30, inscrits: 3, quiz: 12 },
]

const favoriteParcours = [
  { name: 'Informatique', value: 120 },
  { name: 'Médecine', value: 95 },
  { name: 'Commerce', value: 80 },
  { name: 'Sciences', value: 65 },
  { name: 'Arts', value: 45 },
  { name: 'Lettres', value: 30 },
]

const niveauDistribution = [
  { name: 'Collège', value: 40, color: '#3730E8' },
  { name: 'Lycée', value: 35, color: '#F59E0B' },
  { name: 'Université', value: 20, color: '#10B981' },
  { name: 'Autre', value: 5, color: '#EF4444' },
]

export default function AdminStatistiquesPage() {
  const { data: kpis } = useQuery({
    queryKey: ['admin-stats-kpis'],
    queryFn: () => statsService.getKPIs(),
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
      title: 'Utilisateurs actifs',
      value: 156,
      icon: Users,
      color: 'blue' as const,
    },
  ]

  const tooltipStyle = {
    borderRadius: 12,
    border: '1px solid #E5E7EB',
    backgroundColor: '#FFFFFF',
  }

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
            Activité quotidienne
          </h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={dailyActivity}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="jour" stroke="#6B7280" fontSize={12} />
                <YAxis stroke="#6B7280" fontSize={12} />
                <Tooltip contentStyle={tooltipStyle} />
                <Line
                  type="monotone"
                  dataKey="visites"
                  stroke="#3730E8"
                  strokeWidth={2}
                  dot={{ fill: '#3730E8', r: 4 }}
                  name="Visites"
                />
                <Line
                  type="monotone"
                  dataKey="inscrits"
                  stroke="#10B981"
                  strokeWidth={2}
                  dot={{ fill: '#10B981', r: 4 }}
                  name="Inscrits"
                />
                <Line
                  type="monotone"
                  dataKey="quiz"
                  stroke="#F59E0B"
                  strokeWidth={2}
                  dot={{ fill: '#F59E0B', r: 4 }}
                  name="Quiz complétés"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-4">
            Parcours favoris
          </h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={favoriteParcours}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="name" stroke="#6B7280" fontSize={12} />
                <YAxis stroke="#6B7280" fontSize={12} />
                <Tooltip contentStyle={tooltipStyle} />
                <Bar
                  dataKey="value"
                  fill="#3730E8"
                  radius={[4, 4, 0, 0]}
                  name="Intérêt"
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-card rounded-[12px] border border-border p-5">
          <h3 className="text-base font-semibold text-text-main mb-4">
            Répartition par niveau
          </h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={niveauDistribution}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={80}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {niveauDistribution.map((entry) => (
                    <Cell key={entry.name} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip contentStyle={tooltipStyle} />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-col gap-2 mt-2">
            {niveauDistribution.map((item) => (
              <div key={item.name} className="flex items-center justify-between text-sm">
                <span className="flex items-center gap-2">
                  <span
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: item.color }}
                  />
                  {item.name}
                </span>
                <span className="font-medium text-text-main">{item.value}%</span>
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
              <p className="text-2xl font-bold text-danger">42</p>
              <p className="text-xs text-text-secondary mt-1">Fiches</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
