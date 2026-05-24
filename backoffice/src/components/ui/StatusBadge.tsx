import { cn } from '@/lib/utils'

const statusColorMap: Record<string, string> = {
  URGENT: 'bg-danger-light text-danger',
  ERREUR: 'bg-danger-light text-danger',
  PUBLIE: 'bg-success-light text-success',
  VALIDE: 'bg-success-light text-success',
  SUCCES: 'bg-success-light text-success',
  INFO: 'bg-success-light text-success',
  REVISION: 'bg-secondary-light text-secondary',
  EN_COURS: 'bg-secondary-light text-secondary',
  EN_ATTENTE: 'bg-secondary-light text-secondary',
  BROUILLON: 'bg-gray-100 text-gray-600',
  NORMAL: 'bg-gray-100 text-gray-600',
  AVERTISSEMENT: 'bg-yellow-50 text-yellow-700',
}

interface StatusBadgeProps {
  status: string
}

export default function StatusBadge({ status }: StatusBadgeProps) {
  const classes = statusColorMap[status] ?? 'bg-gray-100 text-gray-600'

  return (
    <span
      className={cn(
        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
        classes,
      )}
    >
      {status}
    </span>
  )
}
