import { cn } from '@/lib/utils'
import { type LucideIcon, ArrowUp, ArrowDown } from 'lucide-react'

type ColorVariant = 'primary' | 'secondary' | 'success' | 'danger' | 'blue'

interface StatCardProps {
  title: string
  value: string | number
  trend?: number
  trendLabel?: string
  icon: LucideIcon
  color: ColorVariant
}

const colorMap: Record<ColorVariant, { bg: string; text: string; iconBg: string }> = {
  primary: { bg: 'bg-primary-light', text: 'text-primary', iconBg: 'bg-primary' },
  secondary: { bg: 'bg-secondary-light', text: 'text-secondary', iconBg: 'bg-secondary' },
  success: { bg: 'bg-success-light', text: 'text-success', iconBg: 'bg-success' },
  danger: { bg: 'bg-danger-light', text: 'text-danger', iconBg: 'bg-danger' },
  blue: { bg: 'bg-blue-50', text: 'text-blue-600', iconBg: 'bg-blue-600' },
}

export default function StatCard({ title, value, trend, trendLabel, icon: Icon, color }: StatCardProps) {
  const colors = colorMap[color]

  return (
    <div className="bg-card rounded-[12px] border border-border p-5 flex items-start gap-4">
      <div className={cn('rounded-xl p-3 shrink-0', colors.iconBg)}>
        <Icon className="size-6 text-white" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm text-text-secondary truncate">{title}</p>
        <p className="text-2xl font-semibold text-text-main mt-1">{value}</p>
        {trend !== undefined && (
          <div className="flex items-center gap-1 mt-1.5">
            {trend >= 0 ? (
              <ArrowUp className="size-4 text-success" />
            ) : (
              <ArrowDown className="size-4 text-danger" />
            )}
            <span className={cn('text-sm font-medium', trend >= 0 ? 'text-success' : 'text-danger')}>
              {Math.abs(trend)}%
            </span>
            {trendLabel && <span className="text-sm text-text-secondary">{trendLabel}</span>}
          </div>
        )}
      </div>
    </div>
  )
}
