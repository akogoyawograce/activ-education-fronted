import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Bell, CheckCheck, Trash2, Clock, MessageSquare, Calendar, Star, Target, Send } from 'lucide-react'
import * as notificationsService from '@/api/notifications'
import { useAuthStore } from '@/stores/authStore'
import PageHeader from '@/components/shared/PageHeader'
import Modal from '@/components/ui/Modal'

const STYLES: Record<string, { icon: typeof Bell; color: string; bg: string }> = {
  MESSAGE: { icon: MessageSquare, color: 'text-blue-600', bg: 'bg-blue-50' },
  DIAGNOSTIC: { icon: Target, color: 'text-orange-600', bg: 'bg-orange-50' },
  RDV: { icon: Calendar, color: 'text-green-600', bg: 'bg-green-50' },
  RECOMMANDATION: { icon: Star, color: 'text-amber-600', bg: 'bg-amber-50' },
}

function styleForTitre(titre: string) {
  const upper = titre.toUpperCase()
  if (upper.includes('MESSAGE')) return STYLES.MESSAGE
  if (upper.includes('DIAGNOSTIC') || upper.includes('QUIZ')) return STYLES.DIAGNOSTIC
  if (upper.includes('RDV') || upper.includes('RENDEZ')) return STYLES.RDV
  if (upper.includes('RECOMMAND')) return STYLES.RECOMMANDATION
  return { icon: Bell, color: 'text-gray-500', bg: 'bg-gray-50' }
}

function formatDate(dateStr: string) {
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return "À l'instant"
  if (mins < 60) return `Il y a ${mins}m`
  const hours = Math.floor(mins / 60)
  if (hours < 24) return `Il y a ${hours}h`
  const days = Math.floor(hours / 24)
  if (days < 7) return `Il y a ${days}j`
  return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}

export default function NotificationsPage() {
  const { trackingId } = useAuthStore()
  const queryClient = useQueryClient()
  const [filter, setFilter] = useState<'all' | 'unread'>('all')
  const [showSend, setShowSend] = useState(false)
  const [sendTitre, setSendTitre] = useState('')
  const [sendMessage, setSendMessage] = useState('')
  const [sendUserId, setSendUserId] = useState('')

  const { data: notifications = [], isLoading } = useQuery({
    queryKey: ['notifications', trackingId],
    queryFn: () => notificationsService.getAll(trackingId!),
    enabled: !!trackingId,
  })

  const { data: nonLues = [] } = useQuery({
    queryKey: ['notifications', 'non-lues', trackingId],
    queryFn: () => notificationsService.getNonLues(trackingId!),
    enabled: !!trackingId,
  })

  const markReadMutation = useMutation({
    mutationFn: (id: string) => notificationsService.markAsRead(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['notifications'] }),
  })

  const markAllReadMutation = useMutation({
    mutationFn: () => notificationsService.markAllAsRead(trackingId!),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['notifications'] }),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => notificationsService.remove(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['notifications'] }),
  })

  const sendMutation = useMutation({
    mutationFn: ({ userId, titre, message }: { userId: string; titre: string; message: string }) =>
      notificationsService.sendNotification(userId, titre, message),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] })
      setShowSend(false)
      setSendTitre('')
      setSendMessage('')
      setSendUserId('')
    },
  })

  const filtered = filter === 'unread'
    ? notifications.filter((n) => !n.lue)
    : notifications

  return (
    <div className="p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <PageHeader
          title={`Notifications${nonLues.length > 0 ? ` (${nonLues.length} non lues)` : ''}`}
          description="Consultez toutes vos notifications"
        />
        <div className="flex items-center gap-3">
          <div className="flex rounded-lg border border-border overflow-hidden text-sm">
            <button
              onClick={() => setFilter('all')}
              className={`px-3 py-1.5 transition-colors ${filter === 'all' ? 'bg-primary text-white' : 'bg-card text-text-secondary hover:text-text-main'}`}
            >
              Toutes
            </button>
            <button
              onClick={() => setFilter('unread')}
              className={`px-3 py-1.5 transition-colors ${filter === 'unread' ? 'bg-primary text-white' : 'bg-card text-text-secondary hover:text-text-main'}`}
            >
              Non lues
            </button>
          </div>
          <button
            onClick={() => setShowSend(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-primary hover:bg-primary-light rounded-lg transition-colors"
          >
            <Send className="w-4 h-4" />
            Envoyer
          </button>
          {notifications.some((n) => !n.lue) && (
            <button
              onClick={() => markAllReadMutation.mutate()}
              className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-primary hover:text-primary-dark transition-colors"
            >
              <CheckCheck className="w-4 h-4" />
              Tout lire
            </button>
          )}
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-24 bg-gray-100 rounded-xl animate-pulse" />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-20 text-text-secondary">
          <Bell className="w-12 h-12 mx-auto mb-4 opacity-40" />
          <p className="text-lg font-medium">Aucune notification</p>
          <p className="text-sm mt-1">
            {filter === 'unread' ? 'Toutes les notifications sont lues' : 'Vous n\'avez pas encore de notifications'}
          </p>
        </div>
      ) : (
        <div className="space-y-2">
          {filtered.map((notif) => {
            const style = styleForTitre(notif.titre)
            const Icon = style.icon
            return (
              <div
                key={notif.trackingId}
                className={`group flex items-start gap-4 p-4 rounded-xl border transition-colors ${
                  !notif.lue
                    ? 'bg-blue-50/50 border-blue-200'
                    : 'bg-card border-border hover:border-blue-200'
                }`}
              >
                <div className={`w-10 h-10 rounded-lg ${style.bg} flex items-center justify-center shrink-0`}>
                  <Icon className={`w-5 h-5 ${style.color}`} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <p className={`text-sm ${!notif.lue ? 'font-semibold text-text-main' : 'text-text-main'}`}>
                        {notif.titre}
                      </p>
                      <p className="text-sm text-text-secondary mt-0.5 line-clamp-2">
                        {notif.message}
                      </p>
                    </div>
                    {!notif.lue && (
                      <span className="w-2 h-2 rounded-full bg-primary shrink-0 mt-2" />
                    )}
                  </div>
                  <div className="flex items-center gap-3 mt-2">
                    <span className="flex items-center gap-1 text-xs text-text-light">
                      <Clock className="w-3 h-3" />
                      {formatDate(notif.createdAt)}
                    </span>
                    {!notif.lue && (
                      <button
                        onClick={() => markReadMutation.mutate(notif.trackingId)}
                        className="text-xs text-primary hover:underline opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        Marquer comme lue
                      </button>
                    )}
                    <button
                      onClick={() => deleteMutation.mutate(notif.trackingId)}
                      className="text-xs text-danger hover:underline opacity-0 group-hover:opacity-100 transition-opacity ml-auto"
                    >
                      <Trash2 className="w-3.5 h-3.5 inline" />
                    </button>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      )}

      <Modal
        open={showSend}
        onClose={() => { setShowSend(false); setSendTitre(''); setSendMessage(''); setSendUserId('') }}
        title="Envoyer une notification"
        size="sm"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">ID Utilisateur</label>
            <input
              value={sendUserId}
              onChange={(e) => setSendUserId(e.target.value)}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              placeholder="Tracking ID du destinataire"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Titre</label>
            <input
              value={sendTitre}
              onChange={(e) => setSendTitre(e.target.value)}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
              placeholder="Titre de la notification"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Message</label>
            <textarea
              rows={4}
              value={sendMessage}
              onChange={(e) => setSendMessage(e.target.value)}
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              placeholder="Contenu du message"
            />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button
              onClick={() => { setShowSend(false); setSendTitre(''); setSendMessage(''); setSendUserId('') }}
              className="px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-main border border-border rounded-lg hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              onClick={() => sendMutation.mutate({ userId: sendUserId, titre: sendTitre, message: sendMessage })}
              disabled={sendMutation.isPending || !sendUserId || !sendTitre}
              className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary-dark rounded-lg transition-colors disabled:opacity-50"
            >
              {sendMutation.isPending ? (
                <span className="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <Send className="size-4" />
              )}
              Envoyer
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
