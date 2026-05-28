import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

import LoginPage from '@/pages/login/LoginPage'
import NotFoundPage from '@/pages/NotFoundPage'
import AppLayout from '@/components/layout/AppLayout'
import ProtectedRoute from '@/components/layout/ProtectedRoute'

import ConseillerDashboard from '@/pages/conseiller/ConseillerDashboard'
import RendezVousPage from '@/pages/conseiller/RendezVousPage'
import MessagesPage from '@/pages/conseiller/MessagesPage'
import FAQPage from '@/pages/conseiller/FAQPage'
import UtilisateursPage from '@/pages/conseiller/UtilisateursPage'
import ProfilPage from '@/pages/conseiller/ProfilPage'
import StatistiquesPage from '@/pages/conseiller/StatistiquesPage'

import AdminDashboard from '@/pages/admin/AdminDashboard'
import ElevesPage from '@/pages/admin/ElevesPage'
import ParentsPage from '@/pages/admin/ParentsPage'
import FilieresPage from '@/pages/admin/FilieresPage'
import MetiersPage from '@/pages/admin/MetiersPage'
import SeriesPage from '@/pages/admin/SeriesPage'
import EtablissementsPage from '@/pages/admin/EtablissementsPage'
import QuizPage from '@/pages/admin/QuizPage'
import QuizEditorPage from '@/pages/admin/QuizEditorPage'
import ConseillersPage from '@/pages/admin/ConseillersPage'
import FAQModerationPage from '@/pages/admin/FAQModerationPage'
import SeuilsPage from '@/pages/admin/SeuilsPage'
import AdminStatistiquesPage from '@/pages/admin/AdminStatistiquesPage'
import AdminProfilPage from '@/pages/admin/AdminProfilPage'
import NotificationsPage from '@/pages/admin/NotificationsPage'

import SuperAdminDashboard from '@/pages/superadmin/SuperAdminDashboard'
import ParametresPage from '@/pages/superadmin/ParametresPage'
import LogsPage from '@/pages/superadmin/LogsPage'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,
      gcTime: 10 * 60 * 1000,
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
})

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />

          <Route element={<ProtectedRoute allowedRoles={['CONSEILLER']} />}>
            <Route element={<AppLayout />}>
              <Route path="/conseiller" element={<Navigate to="/conseiller/dashboard" replace />} />
              <Route path="/conseiller/dashboard" element={<ConseillerDashboard />} />
              <Route path="/conseiller/rendez-vous" element={<RendezVousPage />} />
              <Route path="/conseiller/messages" element={<MessagesPage />} />
              <Route path="/conseiller/faq" element={<FAQPage />} />
              <Route path="/conseiller/utilisateurs" element={<UtilisateursPage />} />
              <Route path="/conseiller/profil" element={<ProfilPage />} />
              <Route path="/conseiller/statistiques" element={<StatistiquesPage />} />
              <Route path="/conseiller/notifications" element={<NotificationsPage />} />
            </Route>
          </Route>

          <Route element={<ProtectedRoute allowedRoles={['ADMIN', 'SUPER_ADMIN']} />}>
            <Route element={<AppLayout />}>
              <Route path="/admin" element={<Navigate to="/admin/dashboard" replace />} />
              <Route path="/admin/dashboard" element={<AdminDashboard />} />
              <Route path="/admin/eleves" element={<ElevesPage />} />
              <Route path="/admin/parents" element={<ParentsPage />} />
              <Route path="/admin/filieres" element={<FilieresPage />} />
              <Route path="/admin/metiers" element={<MetiersPage />} />
              <Route path="/admin/series" element={<SeriesPage />} />
              <Route path="/admin/etablissements" element={<EtablissementsPage />} />
              <Route path="/admin/quiz" element={<QuizPage />} />
              <Route path="/admin/quiz/:id/edit" element={<QuizEditorPage />} />
              <Route path="/admin/conseillers" element={<ConseillersPage />} />
              <Route path="/admin/faq" element={<FAQModerationPage />} />
              <Route path="/admin/seuils" element={<SeuilsPage />} />
              <Route path="/admin/statistiques" element={<AdminStatistiquesPage />} />
              <Route path="/admin/profil" element={<AdminProfilPage />} />
              <Route path="/admin/notifications" element={<NotificationsPage />} />
            </Route>
          </Route>

          <Route element={<ProtectedRoute allowedRoles={['SUPER_ADMIN']} />}>
            <Route element={<AppLayout />}>
              <Route path="/superadmin" element={<Navigate to="/superadmin/dashboard" replace />} />
              <Route path="/superadmin/dashboard" element={<SuperAdminDashboard />} />
              <Route path="/superadmin/parametres" element={<ParametresPage />} />
              <Route path="/superadmin/logs" element={<LogsPage />} />
              <Route path="/superadmin/eleves" element={<ElevesPage />} />
              <Route path="/superadmin/parents" element={<ParentsPage />} />
              <Route path="/superadmin/filieres" element={<FilieresPage />} />
              <Route path="/superadmin/metiers" element={<MetiersPage />} />
              <Route path="/superadmin/series" element={<SeriesPage />} />
              <Route path="/superadmin/etablissements" element={<EtablissementsPage />} />
              <Route path="/superadmin/quiz" element={<QuizPage />} />
              <Route path="/superadmin/quiz/:id/edit" element={<QuizEditorPage />} />
              <Route path="/superadmin/conseillers" element={<ConseillersPage />} />
              <Route path="/superadmin/faq" element={<FAQModerationPage />} />
              <Route path="/superadmin/seuils" element={<SeuilsPage />} />
              <Route path="/superadmin/statistiques" element={<AdminStatistiquesPage />} />
              <Route path="/superadmin/profil" element={<AdminProfilPage />} />
              <Route path="/superadmin/notifications" element={<NotificationsPage />} />
            </Route>
          </Route>

          <Route path="/" element={<Navigate to="/login" replace />} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  )
}
