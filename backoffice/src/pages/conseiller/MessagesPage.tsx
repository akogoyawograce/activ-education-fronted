import { useState, useRef, useEffect, useCallback } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { format, parseISO } from 'date-fns'
import { fr } from 'date-fns/locale'
import { MessageSquare, Send, Search, Plus, ArrowLeft, Check, CheckCheck } from 'lucide-react'
import { useAuthStore } from '@/stores/authStore'
import * as messageService from '@/api/messages'
import UserAvatar from '@/components/ui/UserAvatar'
import Modal from '@/components/ui/Modal'
import type { MessageResponse } from '@/types'

interface Conversation {
  contactId: string
  messages: MessageResponse[]
  lastMessage: MessageResponse
  unreadCount: number
}

function groupConversations(
  recus: MessageResponse[],
  envoyes: MessageResponse[],
): Conversation[] {
  const contacts = new Map<string, MessageResponse[]>()

  for (const msg of recus) {
    const id = msg.expediteurTrackingId
    if (!contacts.has(id)) contacts.set(id, [])
    contacts.get(id)!.push(msg)
  }

  for (const msg of envoyes) {
    const id = msg.destinataireTrackingId
    if (!contacts.has(id)) contacts.set(id, [])
    contacts.get(id)!.push(msg)
  }

  return Array.from(contacts.entries())
    .map(([contactId, msgs]) => {
      msgs.sort((a, b) => new Date(b.dateEnvoi).getTime() - new Date(a.dateEnvoi).getTime())
      const unreadCount = msgs.filter(
        (m) => !m.lu && m.expediteurTrackingId === contactId,
      ).length
      return {
        contactId,
        messages: msgs,
        lastMessage: msgs[0],
        unreadCount,
      }
    })
    .sort(
      (a, b) =>
        new Date(b.lastMessage.dateEnvoi).getTime() -
        new Date(a.lastMessage.dateEnvoi).getTime(),
    )
}

function formatMsgTime(dateStr: string) {
  const date = parseISO(dateStr)
  const now = new Date()
  const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24))
  if (diffDays === 0) return format(date, 'HH:mm')
  if (diffDays === 1) return 'Hier'
  if (diffDays < 7) return format(date, 'EEEE', { locale: fr })
  return format(date, 'dd/MM')
}

export default function MessagesPage() {
  const trackingId = useAuthStore((s) => s.trackingId)
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [selectedContact, setSelectedContact] = useState<string | null>(null)
  const [newMessage, setNewMessage] = useState('')
  const [showNewModal, setShowNewModal] = useState(false)
  const [newRecipientId, setNewRecipientId] = useState('')
  const [newMsgText, setNewMsgText] = useState('')
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const chatContainerRef = useRef<HTMLDivElement>(null)

  const { data: recusPage, isLoading: loadingRecus } = useQuery({
    queryKey: ['messages-recus', trackingId],
    queryFn: () => messageService.getRecus(trackingId!, 0, 50),
    enabled: !!trackingId,
  })

  const { data: envoyesPage } = useQuery({
    queryKey: ['messages-envoyes', trackingId],
    queryFn: () => messageService.getEnvoyes(trackingId!, 0, 50),
    enabled: !!trackingId,
  })

  const recus = recusPage?.content ?? []
  const envoyes = envoyesPage?.content ?? []
  const conversations = groupConversations(recus, envoyes)

  const filtered = search
    ? conversations.filter((c) =>
        c.contactId.toLowerCase().includes(search.toLowerCase()),
      )
    : conversations

  const { data: conversationMessages, isLoading: loadingChat } = useQuery({
    queryKey: ['conversation', trackingId, selectedContact],
    queryFn: () => messageService.getConversation(trackingId!, selectedContact!),
    enabled: !!trackingId && !!selectedContact,
    refetchInterval: 5000,
  })

  useEffect(() => {
    if (selectedContact && conversationMessages && conversationMessages.length > 0) {
      messageService.markAsRead(selectedContact, trackingId!)
      queryClient.invalidateQueries({ queryKey: ['messages-recus', trackingId] })
    }
  }, [selectedContact, conversationMessages, trackingId, queryClient])

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [conversationMessages])

  const sendMutation = useMutation({
    mutationFn: (data: { destinataireTrackingId: string; contenu: string }) =>
      messageService.send(trackingId!, {
        contenu: data.contenu,
        destinataireTrackingId: data.destinataireTrackingId,
      }),
    onSuccess: () => {
      setNewMessage('')
      queryClient.invalidateQueries({ queryKey: ['conversation', trackingId, selectedContact] })
      queryClient.invalidateQueries({ queryKey: ['messages-envoyes', trackingId] })
    },
  })

  const sendNewMutation = useMutation({
    mutationFn: (data: { destinataireTrackingId: string; contenu: string }) =>
      messageService.send(trackingId!, {
        contenu: data.contenu,
        destinataireTrackingId: data.destinataireTrackingId,
      }),
    onSuccess: (_data, variables) => {
      setShowNewModal(false)
      setNewRecipientId('')
      setNewMsgText('')
      setSelectedContact(variables.destinataireTrackingId)
      queryClient.invalidateQueries({ queryKey: ['messages-recus', trackingId] })
      queryClient.invalidateQueries({ queryKey: ['messages-envoyes', trackingId] })
    },
  })

  const handleSend = useCallback(() => {
    if (!newMessage.trim() || !selectedContact) return
    sendMutation.mutate({
      destinataireTrackingId: selectedContact,
      contenu: newMessage.trim(),
    })
  }, [newMessage, selectedContact, sendMutation])

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  const conversationsList = (
    <div className="flex flex-col h-full">
      <div className="p-3 border-b border-border">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {loadingRecus ? (
          <div className="p-4 space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="size-10 rounded-full bg-gray-200 animate-pulse shrink-0" />
                <div className="flex-1 space-y-1.5">
                  <div className="h-3 w-24 bg-gray-200 rounded animate-pulse" />
                  <div className="h-2.5 w-40 bg-gray-100 rounded animate-pulse" />
                </div>
              </div>
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center p-6">
            <MessageSquare className="size-10 text-gray-300 mb-3" />
            <p className="text-sm text-text-secondary">Aucune conversation</p>
            <button
              onClick={() => setShowNewModal(true)}
              className="mt-3 text-sm font-medium text-primary hover:underline"
            >
              Envoyer un nouveau message
            </button>
          </div>
        ) : (
          <div className="divide-y divide-border">
            {filtered.map((conv) => (
              <button
                key={conv.contactId}
                onClick={() => setSelectedContact(conv.contactId)}
                className={`w-full flex items-start gap-3 p-3 text-left transition-colors hover:bg-gray-50 ${
                  selectedContact === conv.contactId ? 'bg-primary-light/30' : ''
                }`}
              >
                <UserAvatar name={conv.contactId} size="md" />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium text-text-main truncate">
                      {conv.contactId.slice(0, 8)}...
                    </span>
                    <span className="text-xs text-text-secondary shrink-0 ml-2">
                      {formatMsgTime(conv.lastMessage.dateEnvoi)}
                    </span>
                  </div>
                  <p className="text-xs text-text-secondary truncate mt-0.5">
                    {conv.lastMessage.contenu}
                  </p>
                </div>
                {conv.unreadCount > 0 && (
                  <span className="size-5 rounded-full bg-primary text-white text-[10px] font-bold flex items-center justify-center shrink-0 mt-1">
                    {conv.unreadCount}
                  </span>
                )}
              </button>
            ))}
          </div>
        )}
      </div>

      <div className="p-3 border-t border-border">
        <button
          onClick={() => setShowNewModal(true)}
          className="w-full flex items-center justify-center gap-2 px-4 py-2 bg-primary text-white rounded-lg text-sm font-medium hover:bg-primary-dark transition-colors"
        >
          <Plus className="size-4" />
          Nouveau message
        </button>
      </div>
    </div>
  )

  const chatView = selectedContact ? (
    <div className="flex flex-col h-full">
      <div className="flex items-center gap-3 px-5 py-3 border-b border-border bg-white">
        <button
          onClick={() => setSelectedContact(null)}
          className="lg:hidden p-1 -ml-1 rounded-lg hover:bg-gray-100"
        >
          <ArrowLeft className="size-5 text-text-secondary" />
        </button>
        <UserAvatar name={selectedContact} size="sm" />
        <div className="min-w-0">
          <p className="text-sm font-medium text-text-main truncate">
            {selectedContact.slice(0, 8)}...
          </p>
          <p className="text-xs text-text-secondary">{selectedContact}</p>
        </div>
      </div>

      <div
        ref={chatContainerRef}
        className="flex-1 overflow-y-auto px-5 py-4 space-y-3 bg-gray-50/50"
      >
        {loadingChat ? (
          <div className="space-y-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className={`flex ${i % 2 === 0 ? '' : 'justify-end'}`}>
                <div className={`h-10 w-48 rounded-lg animate-pulse ${i % 2 === 0 ? 'bg-gray-200' : 'bg-primary/20'}`} />
              </div>
            ))}
          </div>
        ) : conversationMessages && conversationMessages.length > 0 ? (
          <>
            {conversationMessages.map((msg) => {
              const isMine = msg.expediteurTrackingId === trackingId
              return (
                <div
                  key={msg.trackingId}
                  className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}
                >
                  <div
                    className={`max-w-[75%] px-4 py-2.5 rounded-2xl text-sm leading-relaxed ${
                      isMine
                        ? 'bg-primary text-white rounded-br-md'
                        : 'bg-white text-text-main border border-border rounded-bl-md'
                    }`}
                  >
                    <p>{msg.contenu}</p>
                    <div
                      className={`flex items-center gap-1 mt-1 ${
                        isMine ? 'justify-end' : 'justify-start'
                      }`}
                    >
                      <span
                        className={`text-[10px] ${
                          isMine ? 'text-white/70' : 'text-text-secondary'
                        }`}
                      >
                        {format(parseISO(msg.dateEnvoi), 'HH:mm')}
                      </span>
                      {isMine && (
                        msg.lu ? (
                          <CheckCheck className="size-3 text-white/70" />
                        ) : (
                          <Check className="size-3 text-white/70" />
                        )
                      )}
                    </div>
                  </div>
                </div>
              )
            })}
            <div ref={messagesEndRef} />
          </>
        ) : (
          <div className="flex items-center justify-center h-full">
            <p className="text-sm text-text-secondary">
              Aucun message dans cette conversation
            </p>
          </div>
        )}
      </div>

      <div className="flex items-center gap-2 px-5 py-3 border-t border-border bg-white">
        <input
          type="text"
          placeholder="Écrivez votre message..."
          value={newMessage}
          onChange={(e) => setNewMessage(e.target.value)}
          onKeyDown={handleKeyDown}
          className="flex-1 px-4 py-2.5 border border-border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
        <button
          onClick={handleSend}
          disabled={!newMessage.trim() || sendMutation.isPending}
          className="p-2.5 bg-primary text-white rounded-xl hover:bg-primary-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Send className="size-4" />
        </button>
      </div>
    </div>
  ) : (
    <div className="flex items-center justify-center h-full bg-gray-50/50">
      <div className="text-center p-8">
        <div className="size-16 mx-auto mb-4 rounded-full bg-primary-light flex items-center justify-center">
          <MessageSquare className="size-8 text-primary" />
        </div>
        <h3 className="text-lg font-semibold text-text-main mb-1">Messagerie</h3>
        <p className="text-sm text-text-secondary mb-4">
          Sélectionnez une conversation ou démarrez-en une nouvelle
        </p>
        <button
          onClick={() => setShowNewModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-lg text-sm font-medium hover:bg-primary-dark transition-colors"
        >
          <Plus className="size-4" />
          Nouveau message
        </button>
      </div>
    </div>
  )

  return (
    <div className="h-[calc(100vh-6rem)] flex flex-col">
      <div className="flex items-center justify-between px-1 pb-4">
        <div>
          <h1 className="text-2xl font-semibold text-text-main">Messagerie</h1>
          <p className="text-text-secondary text-sm mt-0.5">
            {conversations.length} conversation{conversations.length > 1 ? 's' : ''}
          </p>
        </div>
      </div>

      <div className="flex-1 bg-card rounded-[12px] border border-border overflow-hidden flex">
        <div
          className={`${
            selectedContact ? 'hidden lg:flex' : 'flex'
          } w-full lg:w-[360px] border-r border-border flex-col shrink-0`}
        >
          {conversationsList}
        </div>
        <div className={`flex-1 ${selectedContact ? 'flex' : 'hidden lg:flex'} flex-col`}>
          {chatView}
        </div>
      </div>

      <Modal
        open={showNewModal}
        onClose={() => {
          setShowNewModal(false)
          setNewRecipientId('')
          setNewMsgText('')
        }}
        title="Nouveau message"
        size="sm"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">
              ID du destinataire
            </label>
            <input
              type="text"
              value={newRecipientId}
              onChange={(e) => setNewRecipientId(e.target.value)}
              placeholder="trackingId du destinataire"
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
            <p className="text-xs text-text-secondary mt-1.5">
              Vous trouverez les IDs dans la page Utilisateurs
            </p>
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Message</label>
            <textarea
              rows={3}
              value={newMsgText}
              onChange={(e) => setNewMsgText(e.target.value)}
              placeholder="Écrivez votre message..."
              className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
            />
          </div>
          <div className="flex justify-end gap-3 pt-1">
            <button
              onClick={() => {
                setShowNewModal(false)
                setNewRecipientId('')
                setNewMsgText('')
              }}
              className="px-4 py-2 text-sm font-medium text-text-secondary border border-border rounded-lg hover:bg-gray-50 transition-colors"
            >
              Annuler
            </button>
            <button
              onClick={() => {
                if (newRecipientId.trim() && newMsgText.trim()) {
                  sendNewMutation.mutate({
                    destinataireTrackingId: newRecipientId.trim(),
                    contenu: newMsgText.trim(),
                  })
                }
              }}
              disabled={!newRecipientId.trim() || !newMsgText.trim() || sendNewMutation.isPending}
              className="px-4 py-2 text-sm font-medium text-white bg-primary rounded-lg hover:bg-primary-dark transition-colors disabled:opacity-50"
            >
              {sendNewMutation.isPending ? 'Envoi...' : 'Envoyer'}
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
