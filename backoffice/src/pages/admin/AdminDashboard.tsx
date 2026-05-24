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
import * as eleveService from '@/api/eleves'
import * as conseillerService from '@/api/conseillers'
import * as quizService from '@/api/quiz'
import * as parentService from '@/api/parents'
import KpiCardGrid from '@/components/shared/KpiCardGrid'
import PageHeader from '@/components/shared/PageHeader'
import { SkeletonCard } from '@/components/ui/Skeleton'

const weeklyActivity = [
  { jour: 'Lun', visites: 120, inscriptions: 18 },
  { jour: 'Mar', visites: 95, inscriptions: 12 },
  { jour: 'Mer', visites: 150, inscriptions: 24 },
  { jour: 'Jeu', visites: 110, inscriptions: 15 },
  { jour: 'Ven', visites: 80, inscriptions: 10 },
  { jour: 'Sam', visites: 45, inscriptions: 5 },
  { jour: 'Dim', visites: 30, inscriptions: 3 },
]

const profileDistribution = [
  { name: 'Collégien', value: 45, color: '#3730E8' },
  { name: 'Lycéen', value: 35, color: '#F59E0B' },
  { name: 'Étudiant', value: 20, color: '#10B981' },
]

const recentFiches = [
  { titre: 'Filière Informatique', type: 'Filière', modifiee: '2026-05-21', statut: 'Publié' },
  { titre: 'Série Scientifique', type: 'Série', modifiee: '2026-05-20', statut: 'Publié' },
  { titre: 'Métier Développeur', type: 'Métier', modifiee: '2026-05-19', statut: 'Brouillon' },
  { titre: 'Lycée Technique', type: 'Établissement', modifiee: '2026-05-18', statut: 'Publié' },
]

export default function AdminDashboard() {
  const { data: eleves, isLoading: loadingEleves } = useQuery({
    queryKey: ['admin-dashboard', 'eleves'],
    queryFn: () => eleveService.getAll(0, 1),
  })
  const { data: parents } = useQuery({
    queryKey: ['admin-dashboard', 'parents'],
    queryFn: () => parentService.getAll(0, 1),
  })
  const { data: conseillers, isLoading: loadingConseillers } = useQuery({
    queryKey: ['admin-dashboard', 'conseillers'],
    queryFn: () => conseillerService.getAll(0, 1),
  })
  const { data: quiz, isLoading: loadingQuiz } = useQuery({
    queryKey: ['admin-dashboard', 'quiz'],
    queryFn: () => quizService.getAll(0, 1),
  })
  const isLoading = loadingEleves || loadingConseillers || loadingQuiz

  const kpiItems = [
    {
      title: 'Total Élèves',
      value: eleves?.totalElements ?? 0,
      icon: GraduationCap,
      color: 'primary' as const,
    },
    {
      title: 'Total Parents',
      value: parents?.totalElements ?? 0,
      icon: Users,
      color: 'blue' as const,
    },
    {
      title: 'Conseillers',
      value: conseillers?.totalElements ?? 0,
      icon: Briefcase,
      color: 'secondary' as const,
    },
    {
      title: 'Quiz',
      value: quiz?.totalElements ?? 0,
      icon: FileQuestion,
      color: 'success' as const,
    },
    {
      title: 'Fiches',
      value: 42,
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
          <h3 className="text-base font-semibold text-text-main mb-4">Activité hebdomadaire</h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={weeklyActivity}>
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
                  dataKey="visites"
                  stroke="#3730E8"
                  strokeWidth={2}
                  dot={{ fill: '#3730E8', r: 4 }}
                  name="Visites"
                />
                <Line
                  type="monotone"
                  dataKey="inscriptions"
                  stroke="#10B981"
                  strokeWidth={2}
                  dot={{ fill: '#10B981', r: 4 }}
                  name="Inscriptions"
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
                  data={profileDistribution}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={80}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {profileDistribution.map((entry) => (
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
            {profileDistribution.map((item) => (
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
            {recentFiches.map((fiche, idx) => (
              <tr key={idx}>
                <td className="px-4 py-3 font-medium text-text-main">{fiche.titre}</td>
                <td className="px-4 py-3 text-text-secondary">{fiche.type}</td>
                <td className="px-4 py-3 text-text-secondary">{fiche.modifiee}</td>
                <td className="px-4 py-3">
                  <span
                    className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      fiche.statut === 'Publié'
                        ? 'bg-success-light text-success'
                        : 'bg-gray-100 text-gray-600'
                    }`}
                  >
                    {fiche.statut}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
