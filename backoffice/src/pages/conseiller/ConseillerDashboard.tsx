import { useQuery } from '@tanstack/react-query'
import { Calendar, MessageSquare, TrendingUp, Star } from 'lucide-react'
import { format, formatDistanceToNow, isToday, parseISO } from 'date-fns'
import { fr } from 'date-fns/locale'
import { useAuthStore } from '@/stores/authStore'
import * as rendezvousService from '@/api/rendezvous'
import * as messageService from '@/api/messages'
import * as conseillerService from '@/api/conseillers'
import StatCard from '@/components/ui/StatCard'
import StatusBadge from '@/components/ui/StatusBadge'
import UserAvatar from '@/components/ui/UserAvatar'
import { SkeletonCard, SkeletonList } from '@/components/ui/Skeleton'

export default function ConseillerDashboard() {
  const trackingId = useAuthStore((s) => s.trackingId)
  const userName = useAuthStore((s) => s.userName)

  const { data: rendezVous, isLoading: loadingRdvs } = useQuery({
    queryKey: ['rendezvous', trackingId],
    queryFn: () => rendezvousService.getByConseiller(trackingId!),
    enabled: !!trackingId,
  })

  const { data: messagesPage, isLoading: loadingMsgs } = useQuery({
    queryKey: ['messages', trackingId],
    queryFn: () => messageService.getRecus(trackingId!, 0, 5),
    enabled: !!trackingId,
  })

  const { data: profil, isLoading: loadingProfil } = useQuery({
    queryKey: ['conseiller', trackingId],
    queryFn: () => conseillerService.getById(trackingId!),
    enabled: !!trackingId,
  })

  const todayRdvs = (rendezVous ?? []).filter((r) => isToday(parseISO(r.dateHeurePrevue)))
  const nonLus = messagesPage?.content.filter((m) => !m.lu).length ?? 0
  const totalMessages = messagesPage?.totalElements ?? 0
  const tauxReponse = totalMessages > 0 ? Math.round(((totalMessages - nonLus) / totalMessages) * 100) : 0

  const messages = messagesPage?.content ?? []

  if (loadingRdvs || loadingMsgs || loadingProfil) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-semibold text-text-main">Bon retour, {userName ?? '...'}</h1>
          <p className="text-text-secondary mt-1">Voici un aperçu de votre activité</p>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => <SkeletonCard key={i} />)}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-card rounded-[12px] border border-border p-5">
            <SkeletonList rows={4} />
          </div>
          <div className="bg-card rounded-[12px] border border-border p-5">
            <SkeletonList rows={4} />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-text-main">Bon retour, {profil?.prenom ?? userName ?? '...'}</h1>
        <p className="text-text-secondary mt-1">Voici un aperçu de votre activité</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Rendez-vous aujourd'hui"
          value={todayRdvs.length}
          icon={Calendar}
          color="primary"
          trend={12}
          trendLabel="vs hier"
        />
        <StatCard
          title="Messages non lus"
          value={nonLus}
          icon={MessageSquare}
          color="secondary"
          trend={nonLus > 0 ? 100 : 0}
          trendLabel="non lus"
        />
        <StatCard
          title="Taux de réponse"
          value={`${tauxReponse}%`}
          icon={TrendingUp}
          color="success"
          trend={5}
          trendLabel="ce mois"
        />
        <StatCard
          title="Satisfaction"
          value="4.8/5"
          icon={Star}
          color="blue"
          trend={2}
          trendLabel="ce mois"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-card rounded-[12px] border border-border p-5">
          <h2 className="text-lg font-semibold text-text-main mb-4">Rendez-vous du jour</h2>
          {todayRdvs.length === 0 ? (
            <p className="text-text-secondary text-sm py-8 text-center">
              Aucun rendez-vous prévu aujourd'hui
            </p>
          ) : (
            <div className="space-y-3">
              {todayRdvs.map((rdv) => (
                <div
                  key={rdv.trackingId}
                  className="flex items-center justify-between p-3 rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="text-sm font-medium text-primary">
                      {format(parseISO(rdv.dateHeurePrevue), 'HH:mm')}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-text-main">{rdv.eleveTrackingId}</p>
                      <StatusBadge status={rdv.statut} />
                    </div>
                  </div>
                  <button className="text-xs font-medium text-primary hover:text-primary-dark transition-colors">
                    Démarrer
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="bg-card rounded-[12px] border border-border p-5">
          <h2 className="text-lg font-semibold text-text-main mb-4">Messages récents</h2>
          {messages.length === 0 ? (
            <p className="text-text-secondary text-sm py-8 text-center">Aucun message récent</p>
          ) : (
            <div className="space-y-3">
              {messages.map((msg) => (
                <div
                  key={msg.trackingId}
                  className="flex items-start gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <UserAvatar name="Élève" size="sm" />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium text-text-main truncate">
                        {msg.expediteurTrackingId}
                      </p>
                      <span className="text-xs text-text-secondary shrink-0">
                        {formatDistanceToNow(parseISO(msg.dateEnvoi), {
                          addSuffix: true,
                          locale: fr,
                        })}
                      </span>
                    </div>
                    <p className="text-sm text-text-secondary truncate mt-0.5">{msg.contenu}</p>
                  </div>
                  {!msg.lu && <span className="size-2 rounded-full bg-primary shrink-0 mt-2" />}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
