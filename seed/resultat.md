cat > /home/claude/activ-status/src/App.tsx << 'EOF'
import { useState } from "react"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

const DONE_COLOR = "bg-emerald-500"
const WARN_COLOR = "bg-amber-400"
const TODO_COLOR = "bg-red-400"
const NA_COLOR = "bg-slate-300"

type Status = "done" | "partial" | "todo" | "na"

interface Item {
  name: string
  file?: string
  status: Status
  note?: string
}

interface Section {
  title: string
  icon: string
  items: Item[]
}

const mobileScreens: Section[] = [
  {
    title: "Onboarding & Auth",
    icon: "🔐",
    items: [
      { name: "Splash Screen", file: "splash_screen.dart", status: "done", note: "Animation logo + barre progression" },
      { name: "Onboarding (3 slides)", file: "onboarding_screen.dart", status: "done", note: "PageView, Passer, Suivant" },
      { name: "Profile Setup", file: "profile_setup_screen.dart", status: "done", note: "Rôle, classe, ville" },
      { name: "Register", file: "register_screen.dart", status: "done", note: "Nom, email, téléphone, mot de passe" },
      { name: "Register Preferences", file: "register_preferences_screen.dart", status: "partial", note: "⚠️ City mappée sur etablissementActuel" },
      { name: "Login", file: "login_screen.dart", status: "partial", note: "⚠️ Google Sign-In non implémenté" },
      { name: "Forgot Password", file: "forgot_password_screen.dart", status: "partial", note: "⚠️ API simulée" },
      { name: "OTP", file: "otp_screen.dart", status: "partial", note: "⚠️ Non relié au vrai endpoint" },
    ]
  },
  {
    title: "Dashboard & Navigation",
    icon: "🏠",
    items: [
      { name: "Main Scaffold (5 tabs)", file: "main_scaffold.dart", status: "done" },
      { name: "Dashboard Bachelier", file: "dashboard_bachelier.dart", status: "done", note: "Stats, RDV, messages, pull-to-refresh" },
      { name: "Profile", file: "profile_screen.dart", status: "partial", note: "⚠️ motDePasse placeholder" },
      { name: "Notifications", file: "notifications_screen.dart", status: "partial", note: "⚠️ API delete non disponible" },
      { name: "FAQ", file: "faq_screen.dart", status: "done", note: "Catégories, recherche temps réel" },
      { name: "Dashboard Reconversion", status: "todo", note: "❌ Manquant" },
      { name: "Espace Famille / Résultats Parent", status: "todo", note: "❌ Manquant" },
      { name: "Dashboard Conseiller (mobile)", status: "todo", note: "❌ Manquant" },
    ]
  },
  {
    title: "Explorer (Bibliothèque)",
    icon: "📚",
    items: [
      { name: "Explorer (liste + recherche)", file: "explorer_screen.dart", status: "done", note: "5 tabs, grille, favoris" },
      { name: "Fiche Détail", file: "fiche_detail_screen.dart", status: "partial", note: "⚠️ Lecteur vidéo non implémenté" },
      { name: "Catalogue Filières/Métiers/Séries", status: "todo", note: "❌ Pages dédiées manquantes" },
      { name: "Mes Favoris (standalone)", status: "todo", note: "❌ Manquant" },
      { name: "Résultats de recherche", status: "todo", note: "❌ Manquant" },
      { name: "Exploration Guidée", status: "todo", note: "❌ Manquant" },
    ]
  },
  {
    title: "Diagnostic",
    icon: "🎯",
    items: [
      { name: "Diagnostic Hub", file: "diagnostic_screen.dart", status: "done" },
      { name: "Quiz (RIASEC)", file: "quiz_screen.dart", status: "done", note: "Algorithme complet" },
      { name: "Saisie Notes", file: "notes_screen.dart", status: "done", note: "CRUD avec coefficients" },
      { name: "Résultats", file: "resultats_screen.dart", status: "partial", note: "⚠️ Navigation vers fiche stub" },
    ]
  },
  {
    title: "Messagerie & RDV",
    icon: "💬",
    items: [
      { name: "Messages liste", file: "messages_list_screen.dart", status: "done", note: "Swipe-to-delete, compteur non-lus" },
      { name: "Chat", file: "chat_screen.dart", status: "done", note: "Polling 4s, bulles, auto-scroll" },
      { name: "Prise de RDV", file: "rdv_screen.dart", status: "partial", note: "⚠️ Lien visio non connecté" },
    ]
  },
]

const backendSections: Section[] = [
  {
    title: "APIs REST (179 endpoints)",
    icon: "🔌",
    items: [
      { name: "Profil / Utilisateurs", status: "done", note: "Élève, Parent, Conseiller, Admin — CRUD complet" },
      { name: "Notes manuelles", status: "done", note: "Ajout, liste, modification, suppression" },
      { name: "Historique & Notifications", status: "done", note: "Log d'actions, marquer lu, tout lire" },
      { name: "Diagnostic (Quiz + RIASEC)", status: "done", note: "Quiz, Questions, Réponses, Résultats" },
      { name: "Bibliothèque (Fiches)", status: "done", note: "Série, Filière, Métier, Établissement" },
      { name: "FAQ + Recherche IA (Gemini RAG)", status: "done", note: "Embeddings pgvector + Gemini 2.0 flash-lite" },
      { name: "Favoris", status: "done", note: "Ajouter, lister, supprimer" },
      { name: "Messages & Chat", status: "done", note: "Envoyer, conversation, non-lus, marquer lu" },
      { name: "Rendez-Vous", status: "done", note: "Planifier, annuler, terminer" },
      { name: "Disponibilités Conseiller", status: "done", note: "Créneaux par jour" },
      { name: "Fichiers (MinIO)", status: "done", note: "Upload, download, URL, delete" },
      { name: "Analytics & Tendances", status: "done", note: "Tendances 7j, fiches similaires" },
    ]
  },
  {
    title: "Sécurité & Infra",
    icon: "🔒",
    items: [
      { name: "Spring Security + JWT", status: "todo", note: "🔴 CRITIQUE — Tous les endpoints sont publics" },
      { name: "Authentification Login/Logout", status: "todo", note: "🔴 CRITIQUE — Endpoint /auth/login manquant" },
      { name: "Refresh Token", status: "todo", note: "🔴 CRITIQUE — Non implémenté" },
      { name: "Migrations DB (Flyway)", status: "todo", note: "⚠️ Utilise ddl-auto=update seulement" },
      { name: "Tests unitaires & intégration", status: "todo", note: "⚠️ 1 seul test (contextLoads)" },
      { name: "Tâches planifiées (@Scheduled)", status: "todo", note: "⚠️ Aucune tâche planifiée" },
    ]
  },
]

const adminSections: Section[] = [
  {
    title: "Back-office Admin (React)",
    icon: "🖥️",
    items: [
      { name: "Dashboard Admin (stats globales)", status: "todo", note: "❌ Non commencé" },
      { name: "Gestion Filières (liste + édition)", status: "todo", note: "❌ Non commencé" },
      { name: "Éditeur Quiz (arbre + scoring)", status: "todo", note: "❌ Non commencé" },
      { name: "Gestion Conseillers", status: "todo", note: "❌ Non commencé" },
      { name: "Modération FAQ", status: "todo", note: "❌ Non commencé" },
      { name: "Statistiques & Rapports", status: "todo", note: "❌ Non commencé" },
      { name: "Paramètres & Rôles", status: "todo", note: "❌ Non commencé" },
      { name: "Journaux d'Audit (Logs)", status: "todo", note: "❌ Non commencé" },
      { name: "Dashboard Conseiller (web)", status: "todo", note: "❌ Non commencé" },
      { name: "Tickets & Réponses Conseiller", status: "todo", note: "❌ Non commencé" },
      { name: "Agenda Conseiller", status: "todo", note: "❌ Non commencé" },
    ]
  },
]

const todos = [
  { priority: "🔴", label: "CRITIQUE", text: "Spring Security + JWT — tous les endpoints sont publics" },
  { priority: "🔴", label: "CRITIQUE", text: "Endpoint /auth/login manquant — impossible de se connecter vraiment" },
  { priority: "🟠", label: "IMPORTANT", text: "Back-office React — 10+ écrans, aucun commencé" },
  { priority: "🟠", label: "IMPORTANT", text: "Google Sign-In Flutter non implémenté" },
  { priority: "🟠", label: "IMPORTANT", text: "Lecteur vidéo (fiche_detail_screen.dart)" },
  { priority: "🟠", label: "IMPORTANT", text: "Écrans manquants : Reconversion, Espace Famille, Dashboard Conseiller mobile" },
  { priority: "🟡", label: "AMÉLIORATION", text: "State management → Provider ou Riverpod (actuellement tout en setState)" },
  { priority: "🟡", label: "AMÉLIORATION", text: "WebSocket pour le chat (actuellement polling 4s)" },
  { priority: "🟡", label: "AMÉLIORATION", text: "Stockage offline (SQLite/Hive)" },
  { priority: "🟡", label: "AMÉLIORATION", text: "Migrations DB (Flyway/Liquibase)" },
  { priority: "🟡", label: "AMÉLIORATION", text: "Tests unitaires & d'intégration (backend + Flutter)" },
  { priority: "🟡", label: "AMÉLIORATION", text: "Corriger mapping city → etablissementActuel dans register_preferences_screen.dart" },
  { priority: "🟡", label: "AMÉLIORATION", text: "Aligner couleurs Figma (#1300C8) vs code (#3D35D9)" },
  { priority: "🟡", label: "AMÉLIORATION", text: "Police Inter/Poppins (Figma) vs Nunito (code)" },
]

const statusBadge = (s: Status) => {
  if (s === "done") return <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 rounded-full px-2 py-0.5">✅ Fait</span>
  if (s === "partial") return <span className="inline-flex items-center gap-1 text-xs font-semibold text-amber-700 bg-amber-50 border border-amber-200 rounded-full px-2 py-0.5">⚠️ Partiel</span>
  if (s === "todo") return <span className="inline-flex items-center gap-1 text-xs font-semibold text-red-700 bg-red-50 border border-red-200 rounded-full px-2 py-0.5">❌ À faire</span>
  return <span className="text-xs text-slate-400">—</span>
}

const countByStatus = (items: Item[]) => ({
  done: items.filter(i => i.status === "done").length,
  partial: items.filter(i => i.status === "partial").length,
  todo: items.filter(i => i.status === "todo").length,
})

const globalStats = () => {
  const all = [
    ...mobileScreens.flatMap(s => s.items),
    ...backendSections.flatMap(s => s.items),
    ...adminSections.flatMap(s => s.items),
  ]
  return countByStatus(all)
}

function SectionBlock({ section }: { section: Section }) {
  const counts = countByStatus(section.items)
  const total = section.items.length
  const pct = Math.round((counts.done / total) * 100)
  return (
    <div className="mb-6">
      <div className="flex items-center justify-between mb-2">
        <h3 className="font-semibold text-slate-800 text-sm flex items-center gap-2">
          <span>{section.icon}</span> {section.title}
        </h3>
        <span className="text-xs text-slate-500">{counts.done}/{total} — {pct}%</span>
      </div>
      <Progress value={pct} className="h-1.5 mb-3" />
      <div className="space-y-2">
        {section.items.map((item, i) => (
          <div key={i} className="flex items-start justify-between gap-3 py-2 border-b border-slate-100 last:border-0">
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-slate-800">{item.name}</p>
              {item.file && <p className="text-xs text-slate-400 font-mono">{item.file}</p>}
              {item.note && <p className="text-xs text-slate-500 mt-0.5">{item.note}</p>}
            </div>
            <div className="shrink-0">{statusBadge(item.status)}</div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default function App() {
  const stats = globalStats()
  const total = stats.done + stats.partial + stats.todo
  const globalPct = Math.round(((stats.done + stats.partial * 0.5) / total) * 100)

  return (
    <div className="min-h-screen bg-slate-50 font-sans">
      {/* Header */}
      <div className="bg-white border-b border-slate-200 px-6 py-5 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto flex items-center justify-between flex-wrap gap-4">
          <div>
            <h1 className="text-xl font-bold text-slate-900">Activ Education</h1>
            <p className="text-sm text-slate-500">État du projet — Vue d'ensemble complète</p>
          </div>
          <div className="flex items-center gap-3">
            <div className="text-right">
              <p className="text-2xl font-black text-slate-900">{globalPct}%</p>
              <p className="text-xs text-slate-500">progression globale</p>
            </div>
            <div className="w-16 h-16 relative">
              <svg viewBox="0 0 36 36" className="w-16 h-16 -rotate-90">
                <circle cx="18" cy="18" r="15.9" fill="none" stroke="#e2e8f0" strokeWidth="3.5"/>
                <circle cx="18" cy="18" r="15.9" fill="none" stroke="#3D35D9"
                  strokeWidth="3.5" strokeDasharray={`${globalPct} ${100 - globalPct}`}
                  strokeLinecap="round"/>
              </svg>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Stats rapides */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          {[
            { label: "Terminé", val: stats.done, color: "text-emerald-600", bg: "bg-emerald-50 border-emerald-200" },
            { label: "Partiel", val: stats.partial, color: "text-amber-600", bg: "bg-amber-50 border-amber-200" },
            { label: "À faire", val: stats.todo, color: "text-red-600", bg: "bg-red-50 border-red-200" },
          ].map(s => (
            <div key={s.label} className={`rounded-xl border p-4 text-center ${s.bg}`}>
              <p className={`text-3xl font-black ${s.color}`}>{s.val}</p>
              <p className="text-xs font-medium text-slate-600 mt-1">{s.label}</p>
            </div>
          ))}
        </div>

        {/* Tabs */}
        <Tabs defaultValue="mobile">
          <TabsList className="w-full mb-6 grid grid-cols-4">
            <TabsTrigger value="mobile">📱 Mobile</TabsTrigger>
            <TabsTrigger value="backend">⚙️ Backend</TabsTrigger>
            <TabsTrigger value="admin">🖥️ Admin</TabsTrigger>
            <TabsTrigger value="todos">📋 TODOs</TabsTrigger>
          </TabsList>

          <TabsContent value="mobile">
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center justify-between">
                  <span>Flutter Mobile — {mobileScreens.flatMap(s=>s.items).filter(i=>i.status==="done").length}/{mobileScreens.flatMap(s=>s.items).length} écrans</span>
                  <Badge variant="outline" className="font-normal text-xs">Stack : Flutter + Dio + setState</Badge>
                </CardTitle>
              </CardHeader>
              <CardContent>
                {mobileScreens.map((s, i) => <SectionBlock key={i} section={s} />)}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="backend">
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center justify-between">
                  <span>Spring Boot — 179 endpoints</span>
                  <Badge variant="outline" className="font-normal text-xs">Java 21 + PostgreSQL + MinIO + Gemini</Badge>
                </CardTitle>
              </CardHeader>
              <CardContent>
                {backendSections.map((s, i) => <SectionBlock key={i} section={s} />)}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="admin">
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center justify-between">
                  <span>Back-office React — 0/11 écrans</span>
                  <Badge variant="destructive" className="text-xs">Non commencé</Badge>
                </CardTitle>
              </CardHeader>
              <CardContent>
                {adminSections.map((s, i) => <SectionBlock key={i} section={s} />)}
                <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-xl text-sm text-blue-800">
                  <p className="font-semibold mb-1">ℹ️ Les APIs existent déjà côté backend.</p>
                  <p>Il faut créer le projet React/Vite, configurer Axios, et développer les 11 écrans admin.</p>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="todos">
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base">Priorités & Améliorations</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {todos.map((t, i) => (
                    <div key={i} className={`flex items-start gap-3 p-3 rounded-lg border ${
                      t.priority === "🔴" ? "bg-red-50 border-red-200" :
                      t.priority === "🟠" ? "bg-orange-50 border-orange-200" :
                      "bg-yellow-50 border-yellow-200"
                    }`}>
                      <span className="text-lg shrink-0">{t.priority}</span>
                      <div>
                        <span className={`text-xs font-bold mr-2 ${
                          t.priority === "🔴" ? "text-red-700" :
                          t.priority === "🟠" ? "text-orange-700" : "text-yellow-700"
                        }`}>{t.label}</span>
                        <span className="text-sm text-slate-700">{t.text}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        {/* Prompt de continuité */}
        <Card className="mt-6 border-slate-200">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-slate-700">📋 Prompt de continuité</CardTitle>
          </CardHeader>
          <CardContent>
            <pre className="text-xs text-slate-600 whitespace-pre-wrap bg-slate-50 rounded-lg p-4 border border-slate-200 leading-relaxed">
{`Projet : Activ Education — Plateforme d'orientation scolaire (Togo)
Backend : Spring Boot Java 21, PostgreSQL, MinIO, Gemini AI — http://localhost:8080
Mobile : Flutter + Dio + setState — lib/ structuré par feature
Admin : React/Vite — NON COMMENCÉ

BASE URL API : http://localhost:8080
(ou ngrok : https://[id].ngrok-free.app)

DESIGN : Primary #3D35D9, Accent #FFA800, Police Nunito
STRUCTURE Flutter :
  lib/theme/         → app_theme.dart, app_routes.dart
  lib/models/        → models.dart
  lib/services/      → api_service.dart
  lib/widgets/       → common_widgets.dart, bottom_nav.dart
  lib/screens/auth/  → login, register, otp, forgot_password...
  lib/screens/home/  → dashboard_bachelier, notifications
  lib/screens/explorer/    → explorer, fiche_detail
  lib/screens/diagnostic/  → diagnostic, quiz, notes, resultats
  lib/screens/messages/    → messages_list, chat, rdv
  lib/screens/profile/     → profile_screen

PRIORITÉS IMMÉDIATES :
1. 🔴 Spring Security + JWT (backend non sécurisé)
2. 🔴 Endpoint /api/v1/auth/login + /auth/refresh
3. 🖥️ Back-office React (Dashboard Admin, Conseillers, Quiz éditeur...)
4. 📱 Écrans manquants : Reconversion, Espace Famille, Conseiller mobile

NOUVEAUX ENDPOINTS À NOTER :
GET /api/v1/bibliotheque/metiers/recherche?motCle=...
GET /api/v1/bibliotheque/faq/recherche-ia?question=...
GET /api/v1/bibliotheque/recherche-fiche-ia/globale?phrase=...
GET /api/v1/bibliotheque/analytics/tendances
GET /api/v1/bibliotheque/analytics/similaires/{trackingId}
GET /api/v1/bibliotheque/filieres/domaines
GET /api/v1/bibliotheque/etablissements/villes`}
            </pre>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
EOF
echo "App.tsx written"
Sortie

App.tsx written
