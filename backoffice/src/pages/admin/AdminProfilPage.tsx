import { useQuery } from '@tanstack/react-query'
import { getById } from '@/api/administrateurs'
import { useAuthStore } from '@/stores/authStore'
import { User, Shield, Mail, Phone, Calendar } from 'lucide-react'
import { SkeletonList } from '@/components/ui/Skeleton'

export default function AdminProfilPage() {
  const { trackingId, niveauAcces, userName } = useAuthStore()

  const { data, isLoading } = useQuery({
    queryKey: ['admin-profil', trackingId],
    queryFn: () => getById(trackingId!),
    enabled: !!trackingId,
  })

  if (isLoading) return <div className="p-6"><SkeletonList rows={5} /></div>

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="bg-card rounded-[12px] border border-border px-6 py-4">
        <h1 className="text-xl font-semibold text-text-main">Mon Profil</h1>
        <p className="text-sm text-text-secondary mt-0.5">Informations de votre compte administrateur</p>
      </div>

      <div className="bg-card rounded-[12px] border border-border p-6">
        <div className="flex items-center gap-4 pb-5 border-b border-border mb-5">
          <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center">
            <span className="text-xl font-bold text-primary">
              {userName?.split(' ').map(s => s[0]).join('').slice(0, 2) || 'AD'}
            </span>
          </div>
          <div>
            <h2 className="text-lg font-semibold text-text-main">{userName}</h2>
            <span className="inline-flex items-center gap-1 text-xs font-medium text-primary bg-primary-light px-2.5 py-0.5 rounded-full">
              <Shield className="size-3" />
              {niveauAcces || 'Administrateur'}
            </span>
          </div>
        </div>

        {data && (
          <div className="space-y-4">
            <InfoRow icon={User} label="Nom" value={`${data.prenom} ${data.nom}`} />
            <InfoRow icon={Mail} label="Email" value={data.email} />
            <InfoRow icon={Phone} label="Téléphone" value={data.telephone || 'Non renseigné'} />
            <InfoRow icon={Shield} label="Niveau d'accès" value={data.niveauAcces || 'MODERATEUR'} />
            <InfoRow icon={Calendar} label="Inscrit le" value={data.createdAt ? new Date(data.createdAt).toLocaleDateString('fr-FR') : '-'} />
          </div>
        )}
      </div>
    </div>
  )
}

function InfoRow({ icon: Icon, label, value }: { icon: React.ComponentType<{ className?: string }>; label: string; value: string }) {
  return (
    <div className="flex items-center gap-3">
      <div className="w-9 h-9 bg-gray-100 rounded-lg flex items-center justify-center shrink-0">
        <Icon className="size-4 text-text-secondary" />
      </div>
      <div>
        <p className="text-xs text-text-secondary">{label}</p>
        <p className="text-sm font-medium text-text-main">{value}</p>
      </div>
    </div>
  )
}
