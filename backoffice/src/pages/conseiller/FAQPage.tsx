import { useState, useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Search, ChevronDown, ChevronUp } from 'lucide-react'
import * as bibliothequeService from '@/api/bibliotheque'
import PageHeader from '@/components/shared/PageHeader'
import { SkeletonCard } from '@/components/ui/Skeleton'

export default function FAQPage() {
  const [search, setSearch] = useState('')
  const [selectedCategory, setSelectedCategory] = useState<string>('TOUS')
  const [expandedId, setExpandedId] = useState<string | null>(null)

  const { data: faqPage, isLoading } = useQuery({
    queryKey: ['faq'],
    queryFn: () => bibliothequeService.getAllFAQ(0, 100),
  })

  const faqItems = useMemo(() => {
    const items = (faqPage?.content ?? []).filter((f) => f.estPublie)
    const filtered = search
      ? items.filter(
          (f) =>
            f.question.toLowerCase().includes(search.toLowerCase()) ||
            f.reponse.toLowerCase().includes(search.toLowerCase()),
        )
      : items
    return selectedCategory === 'TOUS'
      ? filtered
      : filtered.filter((f) => f.categorie === selectedCategory)
  }, [faqPage, search, selectedCategory])

  const categories = useMemo(() => {
    const cats = new Set((faqPage?.content ?? []).filter((f) => f.estPublie).map((f) => f.categorie))
    return ['TOUS', ...Array.from(cats)]
  }, [faqPage])

  if (isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader title="FAQ" description="Questions fréquemment posées" />
        <div className="grid grid-cols-1 gap-4">
          {Array.from({ length: 5 }).map((_, i) => <SkeletonCard key={i} />)}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <PageHeader title="FAQ" description="Consultez les questions fréquemment posées" />

      <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher une question..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2 bg-card border border-border rounded-[12px] text-sm text-text-main placeholder:text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
          />
        </div>
      </div>

      <div className="flex items-center gap-2 flex-wrap">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`px-3 py-1.5 rounded-full text-xs font-medium transition-colors ${
              selectedCategory === cat
                ? 'bg-primary text-white'
                : 'bg-gray-100 text-text-secondary hover:bg-gray-200'
            }`}
          >
            {cat === 'TOUS' ? 'Toutes' : cat}
          </button>
        ))}
      </div>

      {faqItems.length === 0 ? (
        <div className="bg-card rounded-[12px] border border-border p-12 text-center">
          <p className="text-text-secondary">Aucune question trouvée</p>
        </div>
      ) : (
        <div className="space-y-3">
          {faqItems.map((faq) => (
            <div
              key={faq.trackingId}
              className="bg-card rounded-[12px] border border-border overflow-hidden"
            >
              <button
                onClick={() => setExpandedId(expandedId === faq.trackingId ? null : faq.trackingId)}
                className="w-full flex items-center justify-between p-4 text-left hover:bg-gray-50 transition-colors"
              >
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-text-main">{faq.question}</p>
                  <span className="text-xs text-text-secondary mt-0.5 block">{faq.categorie}</span>
                </div>
                {expandedId === faq.trackingId ? (
                  <ChevronUp className="size-5 text-text-secondary shrink-0" />
                ) : (
                  <ChevronDown className="size-5 text-text-secondary shrink-0" />
                )}
              </button>
              {expandedId === faq.trackingId && (
                <div className="px-4 pb-4 pt-0">
                  <p className="text-sm text-text-secondary leading-relaxed">{faq.reponse}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
