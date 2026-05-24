import { cn } from '@/lib/utils'

const sizeMap = {
  sm: 'size-8 text-xs',
  md: 'size-10 text-sm',
  lg: 'size-12 text-base',
}

const dotSizeMap = {
  sm: 'size-2.5',
  md: 'size-3',
  lg: 'size-3.5',
}

const colors = [
  'bg-blue-500',
  'bg-emerald-500',
  'bg-violet-500',
  'bg-rose-500',
  'bg-amber-500',
  'bg-cyan-500',
  'bg-pink-500',
  'bg-indigo-500',
]

function getColor(name: string): string {
  let hash = 0
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash)
  }
  return colors[Math.abs(hash) % colors.length]
}

interface UserAvatarProps {
  name: string
  imageUrl?: string
  size?: 'sm' | 'md' | 'lg'
  onlineStatus?: boolean
}

export default function UserAvatar({ name, imageUrl, size = 'md', onlineStatus }: UserAvatarProps) {
  const initial = name.charAt(0).toUpperCase()
  const bgColor = getColor(name)

  return (
    <div className="relative inline-flex shrink-0">
      {imageUrl ? (
        <img
          src={imageUrl}
          alt={name}
          className={cn('rounded-full object-cover', sizeMap[size])}
        />
      ) : (
        <div
          className={cn(
            'rounded-full flex items-center justify-center text-white font-medium',
            sizeMap[size],
            bgColor,
          )}
        >
          {initial}
        </div>
      )}
      {onlineStatus && (
        <span
          className={cn(
            'absolute bottom-0 right-0 rounded-full ring-2 ring-card bg-success',
            dotSizeMap[size],
          )}
        />
      )}
    </div>
  )
}
