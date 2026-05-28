import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Check, X, RotateCcw, MessageCircle, Plus, Trash2 } from 'lucide-react'
import * as bibliothequeService from '@/api/bibliotheque'
import StatusBadge from '@/components/ui/StatusBadge'
import PageHeader from '@/components/shared/PageHeader'
import { SkeletonCard } from '@/components/ui/Skeleton'
import Modal from '@/components/ui/Modal'
import type { FAQRequest } from '@/types'

type TabFilter = 'EN_ATTENTE' | 'PUBLIEE' | 'REFUSEE'

const TABS: { key: TabFilter; label: string }[] = [
  { key: 'EN_ATTENTE', label: 'En attente' },
  { key: 'PUBLIEE', label: 'Publiée' },
  { key: 'REFUSEE', label: 'Refusée' },
]

const CATEGORIES = ['ORIENTATION', 'INSCRIPTION', 'BOURSE', 'FILIERE', 'METIER', 'GENERAL'] as const

export default function FAQModerationPage() {
  const queryClient = useQueryClient()
  const [activeTab, setActiveTab] = useState<TabFilter>('EN_ATTENTE')
  const [page, setPage] = useState(1)
  const [createOpen, setCreateOpen] = useState(false)
  const [form, setForm] = useState<FAQRequest>({
    question: '',
    reponse: '',
    categorie: 'GENERAL',
    estPublie: false,
  })

  const { data, isLoading } = useQuery({
    queryKey: ['faq-moderation', page],
    queryFn: () => bibliothequeService.getAllFAQ(page - 1, 20),
  })

  const createMutation = useMutation({
    mutationFn: (data: FAQRequest) => bibliothequeService.createFAQ(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['faq-moderation'] })
      setCreateOpen(false)
      setForm({ question: '', reponse: '', categorie: 'GENERAL', estPublie: false })
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (trackingId: string) => bibliothequeService.deleteFAQ(trackingId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['faq-moderation'] })
    },
  })

  const togglePublishMutation = useMutation({
    mutationFn: async (item: { trackingId: string; estPublie: boolean }) => {
      const faq = await bibliothequeService.getFAQById(item.trackingId)
      return bibliothequeService.updateFAQ(item.trackingId, {
        question: faq.question,
        reponse: faq.reponse,
        categorie: faq.categorie,
        estPublie: !item.estPublie,
      })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['faq-moderation'] })
    },
  })

  const filtered = (data?.content ?? []).filter((item) => {
    if (activeTab === 'EN_ATTENTE') return !item.estPublie
    if (activeTab === 'PUBLIEE') return item.estPublie
    return false
  })

  function getCategoryColor(cat: string) {
    const map: Record<string, string> = {
      ORIENTATION: 'bg-blue-50 text-blue-600',
      INSCRIPTION: 'bg-emerald-50 text-emerald-600',
      BOURSE: 'bg-amber-50 text-amber-600',
      FILIERE: 'bg-violet-50 text-violet-600',
      METIER: 'bg-rose-50 text-rose-600',
      GENERAL: 'bg-gray-50 text-gray-600',
    }
    return map[cat] ?? 'bg-gray-50 text-gray-600'
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Modération FAQ"
        description={`${data?.totalElements ?? 0} entrées`}
        actions={
          <button
            onClick={() => setCreateOpen(true)}
            className="flex items-center gap-1.5 text-sm font-medium bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary/90 transition-colors"
          >
            <Plus className="size-4" />
            Nouvelle FAQ
          </button>
        }
      />

      <div className="flex gap-1 bg-gray-100 p-1 rounded-lg w-fit">
        {TABS.map((tab) => (
          <button
            key={tab.key}
            onClick={() => {
              setActiveTab(tab.key)
              setPage(1)
            }}
            className={`px-4 py-2 text-sm font-medium rounded-md transition-colors ${
              activeTab === tab.key
                ? 'bg-card text-text-main shadow-sm'
                : 'text-text-secondary hover:text-text-main'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <SkeletonCard key={i} />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-card rounded-[12px] border border-border p-12 text-center">
          <MessageCircle className="size-10 text-gray-300 mx-auto mb-3" />
          <p className="text-text-secondary text-sm">
            Aucune entrée FAQ dans cette catégorie
          </p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {filtered.map((item) => (
              <div
                key={item.trackingId}
                className="bg-card rounded-[12px] border border-border p-5 flex flex-col gap-3"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1 min-w-0">
                    <h3 className="text-sm font-semibold text-text-main">
                      {item.question}
                    </h3>
                  </div>
                  <StatusBadge
                    status={item.estPublie ? 'PUBLIE' : 'EN_ATTENTE'}
                  />
                </div>

                <p className="text-sm text-text-secondary line-clamp-3">
                  {item.reponse}
                </p>

                <div className="flex items-center gap-2">
                  <span
                    className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getCategoryColor(item.categorie)}`}
                  >
                    {item.categorie || 'GENERAL'}
                  </span>
                  {item.nbVues > 0 && (
                    <span className="text-xs text-text-secondary">
                      {item.nbVues} vues
                    </span>
                  )}
                </div>

                <div className="flex items-center gap-2 pt-1 border-t border-border">
                  {!item.estPublie && (
                    <>
                      <button
                        onClick={() =>
                          togglePublishMutation.mutate({ trackingId: item.trackingId, estPublie: item.estPublie })
                        }
                        disabled={togglePublishMutation.isPending}
                        className="flex items-center gap-1.5 text-xs font-medium text-success bg-success-light px-3 py-1.5 rounded-lg hover:bg-emerald-200 transition-colors disabled:opacity-50"
                      >
                        <Check className="size-3.5" />
                        Publier
                      </button>
                      <button className="flex items-center gap-1.5 text-xs font-medium text-danger bg-danger-light px-3 py-1.5 rounded-lg hover:bg-red-200 transition-colors">
                        <X className="size-3.5" />
                        Refuser
                      </button>
                    </>
                  )}
                  {item.estPublie && (
                    <button
                      onClick={() =>
                        togglePublishMutation.mutate({ trackingId: item.trackingId, estPublie: item.estPublie })
                      }
                      disabled={togglePublishMutation.isPending}
                      className="flex items-center gap-1.5 text-xs font-medium text-secondary bg-secondary-light px-3 py-1.5 rounded-lg hover:bg-amber-200 transition-colors disabled:opacity-50"
                    >
                      <RotateCcw className="size-3.5" />
                      Dépublier
                    </button>
                  )}
                  <button
                    onClick={() => {
                      if (window.confirm('Supprimer cette FAQ ?')) {
                        deleteMutation.mutate(item.trackingId)
                      }
                    }}
                    disabled={deleteMutation.isPending}
                    className="flex items-center gap-1.5 text-xs font-medium text-danger bg-danger-light px-3 py-1.5 rounded-lg hover:bg-red-200 transition-colors ml-auto disabled:opacity-50"
                  >
                    <Trash2 className="size-3.5" />
                    Supprimer
                  </button>
                </div>
              </div>
            ))}
          </div>

          {data && data.totalPages > 1 && (
            <div className="flex items-center justify-between px-4 py-3 bg-card rounded-[12px] border border-border">
              <p className="text-sm text-text-secondary">
                Page {page} / {data.totalPages}
              </p>
              <div className="flex items-center gap-1">
                <button
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page <= 1}
                  className="p-1.5 rounded-lg hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed transition"
                >
                  <svg className="size-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                  </svg>
                </button>
                <button
                  onClick={() => setPage((p) => Math.min(data.totalPages, p + 1))}
                  disabled={page >= data.totalPages}
                  className="p-1.5 rounded-lg hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed transition"
                >
                  <svg className="size-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </button>
              </div>
            </div>
          )}
        </>
      )}

      <Modal open={createOpen} onClose={() => setCreateOpen(false)} title="Nouvelle FAQ">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Question</label>
            <textarea
              value={form.question}
              onChange={(e) => setForm((f) => ({ ...f, question: e.target.value }))}
              rows={3}
              className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-text-main outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Réponse</label>
            <textarea
              value={form.reponse}
              onChange={(e) => setForm((f) => ({ ...f, reponse: e.target.value }))}
              rows={4}
              className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-text-main outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-main mb-1">Catégorie</label>
            <select
              value={form.categorie}
              onChange={(e) => setForm((f) => ({ ...f, categorie: e.target.value }))}
              className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-text-main outline-none focus:ring-2 focus:ring-primary"
            >
              {CATEGORIES.map((cat) => (
                <option key={cat} value={cat}>
                  {cat}
                </option>
              ))}
            </select>
          </div>
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={form.estPublie}
              onChange={(e) => setForm((f) => ({ ...f, estPublie: e.target.checked }))}
              className="rounded border-border accent-primary"
            />
            <span className="text-sm text-text-main">Publiée</span>
          </label>
          <div className="flex justify-end gap-2 pt-2">
            <button
              onClick={() => setCreateOpen(false)}
              className="px-4 py-2 text-sm font-medium text-text-secondary bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
            >
              Annuler
            </button>
            <button
              onClick={() => createMutation.mutate(form)}
              disabled={createMutation.isPending || !form.question.trim() || !form.reponse.trim()}
              className="px-4 py-2 text-sm font-medium text-white bg-primary rounded-lg hover:bg-primary/90 transition-colors disabled:opacity-50"
            >
              {createMutation.isPending ? 'Création...' : 'Créer'}
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}
