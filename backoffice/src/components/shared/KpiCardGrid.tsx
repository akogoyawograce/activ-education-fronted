import StatCard from '@/components/ui/StatCard'
import type { LucideIcon } from 'lucide-react'

interface KpiItem {
  title: string
  value: string | number
  trend?: number
  trendLabel?: string
  icon: LucideIcon
  color: 'primary' | 'secondary' | 'success' | 'danger' | 'blue'
}

interface KpiCardGridProps {
  items: KpiItem[]
}

export default function KpiCardGrid({ items }: KpiCardGridProps) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {items.map((item, idx) => (
        <StatCard key={idx} {...item} />
      ))}
    </div>
  )
}
