import { Fragment } from 'react'
import { NavLink, useNavigate } from 'react-router-dom'
import logoSrc from '@/assets/logo.jpeg'
import {
  LayoutDashboard,
  CalendarCheck,
  MessageSquare,
  HelpCircle,
  Users,
  UserCircle,
  BarChart3,
  GraduationCap,
  BookOpen,
  Book,
  FileQuestion,
  Briefcase,
  Settings,
  ClipboardList,
  Building2,
  Table,
  LogOut,
  ChevronRight,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { useAuthStore } from '@/stores/authStore'

interface NavGroup {
  label?: string
  items: { label: string; path: string; icon: typeof LayoutDashboard }[]
}

const CONSEILLER_GROUPS: NavGroup[] = [
  {
    items: [
      { label: 'Tableau de bord', path: '/conseiller/dashboard', icon: LayoutDashboard },
    ],
  },
  {
    label: 'Gestion',
    items: [
      { label: 'Messages', path: '/conseiller/messages', icon: MessageSquare },
      { label: 'Rendez-vous', path: '/conseiller/rendez-vous', icon: CalendarCheck },
      { label: 'Utilisateurs', path: '/conseiller/utilisateurs', icon: Users },
    ],
  },
  {
    label: 'Ressources',
    items: [
      { label: 'FAQ', path: '/conseiller/faq', icon: HelpCircle },
      { label: 'Statistiques', path: '/conseiller/statistiques', icon: BarChart3 },
    ],
  },
  {
    label: 'Compte',
    items: [
      { label: 'Mon Profil', path: '/conseiller/profil', icon: UserCircle },
    ],
  },
]

const ADMIN_GROUPS: NavGroup[] = [
  {
    items: [
      { label: 'Tableau de bord', path: '/admin/dashboard', icon: LayoutDashboard },
    ],
  },
  {
    label: 'Utilisateurs',
    items: [
      { label: 'Étudiants', path: '/admin/eleves', icon: GraduationCap },
      { label: 'Parents', path: '/admin/parents', icon: Users },
      { label: 'Conseillers', path: '/admin/conseillers', icon: Briefcase },
    ],
  },
  {
    label: 'Bibliothèque',
    items: [
      { label: 'Séries', path: '/admin/series', icon: Book },
      { label: 'Filières', path: '/admin/filieres', icon: BookOpen },
      { label: 'Métiers', path: '/admin/metiers', icon: Briefcase },
      { label: 'Établissements', path: '/admin/etablissements', icon: Building2 },
    ],
  },
  {
    label: 'Diagnostic',
    items: [
      { label: 'Quiz', path: '/admin/quiz', icon: FileQuestion },
      { label: 'Seuils', path: '/admin/seuils', icon: ClipboardList },
      { label: 'Matrices', path: '/admin/matrices', icon: Table },
    ],
  },
  {
    label: 'Support',
    items: [
      { label: 'FAQ', path: '/admin/faq', icon: HelpCircle },
      { label: 'Statistiques', path: '/admin/statistiques', icon: BarChart3 },
    ],
  },
  {
    label: 'Compte',
    items: [
      { label: 'Mon Profil', path: '/admin/profil', icon: UserCircle },
    ],
  },
]

const SUPER_ADMIN_EXTRA: NavGroup[] = [
  {
    label: 'Configuration',
    items: [
      { label: 'Paramètres', path: '/superadmin/parametres', icon: Settings },
      { label: "Journaux d'audit", path: '/superadmin/logs', icon: ClipboardList },
    ],
  },
]

export default function Sidebar() {
  const navigate = useNavigate()
  const { userType, niveauAcces, userName, logout } = useAuthStore()

  let groups: NavGroup[]
  let baseLabel: string

  if (userType === 'conseillers') {
    groups = CONSEILLER_GROUPS
    baseLabel = 'Conseiller'
  } else {
    groups = [...ADMIN_GROUPS]
    baseLabel = niveauAcces === 'SUPER_ADMIN' ? 'Super Admin' : 'Administrateur'
    if (niveauAcces === 'SUPER_ADMIN') {
      groups = [...groups, ...SUPER_ADMIN_EXTRA]
    }
  }

  const roleLabel = () => {
    if (userType === 'conseillers') return 'Conseiller'
    if (niveauAcces === 'SUPER_ADMIN') return 'Super Admin'
    if (niveauAcces === 'MODERATEUR') return 'Modérateur'
    if (niveauAcces === 'GESTIONNAIRE_CONSEILLER') return 'Gestionnaire'
    return 'Administrateur'
  }

  const handleLogout = () => {
    logout()
    navigate('/login', { replace: true })
  }

  return (
    <aside className="fixed left-0 top-0 h-screen w-[240px] bg-primary flex flex-col z-30">
      <div className="px-5 pt-6 pb-5 border-b border-white/10 flex flex-col items-center">
        <img src={logoSrc} alt="Activ Education" className="h-10 mb-1" />
        <h2 className="text-white text-sm font-bold tracking-tight">Activ Education</h2>
        <p className="text-white/60 text-xs mt-0.5">Espace {baseLabel}</p>
      </div>

      <nav className="flex-1 overflow-y-auto py-3 px-2">
        {groups.map((group, gi) => (
          <Fragment key={gi}>
            {gi > 0 && <div className="mx-2 my-2 border-t border-white/10" />}
            {group.label && (
              <p className="px-3 py-1.5 text-[10px] font-semibold text-white/40 uppercase tracking-widest">
                {group.label}
              </p>
            )}
            <div className="space-y-0.5">
              {group.items.map((item) => (
                <NavLink
                  key={item.path}
                  to={item.path}
                  className={({ isActive }) =>
                    cn(
                      'flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors group',
                      isActive
                        ? 'bg-white/15 text-white'
                        : 'text-white/70 hover:text-white hover:bg-white/10'
                    )
                  }
                >
                  {({ isActive }) => (
                    <>
                      <item.icon className="w-4 h-4 shrink-0" />
                      <span className="truncate">{item.label}</span>
                      <ChevronRight
                        className={cn(
                          'w-3.5 h-3.5 ml-auto transition-transform',
                          isActive ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-1'
                        )}
                      />
                    </>
                  )}
                </NavLink>
              ))}
            </div>
          </Fragment>
        ))}
      </nav>

      <div className="border-t border-white/10 p-4">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center text-white text-sm font-semibold shrink-0">
            {userName?.charAt(0)?.toUpperCase() || '?'}
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-white text-sm font-medium truncate">{userName || 'Utilisateur'}</p>
            <span className="text-white/60 text-xs">{roleLabel()}</span>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="flex items-center gap-2 w-full px-3 py-2 rounded-lg text-white/70 hover:text-white hover:bg-white/10 text-sm font-medium transition-colors"
        >
          <LogOut className="w-4 h-4" />
          Déconnexion
        </button>
      </div>
    </aside>
  )
}
