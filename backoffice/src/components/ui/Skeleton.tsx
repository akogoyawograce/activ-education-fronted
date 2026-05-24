import { cn } from '@/lib/utils'

function Pulse({ className }: { className?: string }) {
  return <div className={cn('animate-pulse bg-gray-200 rounded', className)} />
}

export function SkeletonRow({ cols = 6 }: { cols?: number }) {
  const widths = ['w-1/4', 'w-1/3', 'w-1/2', 'w-1/4', 'w-1/3', 'w-1/4']
  return (
    <tr>
      {Array.from({ length: cols }).map((_, i) => (
        <td key={i} className="px-4 py-3">
          <Pulse className={cn('h-4', widths[i % widths.length])} />
        </td>
      ))}
    </tr>
  )
}

export function SkeletonCard() {
  return (
    <div className="bg-card rounded-[12px] border border-border p-5">
      <div className="flex items-start gap-4">
        <Pulse className="size-12 rounded-xl shrink-0" />
        <div className="flex-1 space-y-3">
          <Pulse className="h-3 w-1/3" />
          <Pulse className="h-6 w-1/2" />
          <Pulse className="h-3 w-1/4" />
        </div>
      </div>
    </div>
  )
}

export function SkeletonList({ rows = 5 }: { rows?: number }) {
  return (
    <div className="space-y-3">
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="flex items-center gap-3 p-3">
          <Pulse className="size-10 rounded-full shrink-0" />
          <div className="flex-1 space-y-2">
            <Pulse className="h-4 w-1/3" />
            <Pulse className="h-3 w-1/2" />
          </div>
        </div>
      ))}
    </div>
  )
}
