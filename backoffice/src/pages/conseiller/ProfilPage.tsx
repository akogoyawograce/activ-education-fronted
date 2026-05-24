import { useQuery } from '@tanstack/react-query'
import { Mail, Phone, Briefcase, Award, BookOpen, Clock, Calendar } from 'lucide-react'
import { format, parseISO } from 'date-fns'
import { fr } from 'date-fns/locale'
import { useAuthStore } from '@/stores/authStore'
import * as conseillerService from '@/api/conseillers'
import UserAvatar from '@/components/ui/UserAvatar'
import PageHeader from '@/components/shared/PageHeader'
import { SkeletonCard } from '@/components/ui/Skeleton'

export default function ProfilPage() {
  const trackingId = useAuthStore((s) => s.trackingId)

  const { data: profil, isLoading } = useQuery({
    queryKey: ['conseiller', trackingId],
    queryFn: () => conseillerService.getById(trackingId!),
    enabled: !!trackingId,
  })

  if (isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader title="Mon Profil" />
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-1">
            <SkeletonCard />
          </div>
          <div className="lg:col-span-2 space-y-4">
            <SkeletonCard />
            <SkeletonCard />
          </div>
        </div>
      </div>
    )
  }

  if (!profil) {
    return (
      <div className="space-y-6">
        <PageHeader title="Mon Profil" />
        <div className="bg-card rounded-[12px] border border-border p-12 text-center">
          <p className="text-text-secondary">Profil introuvable</p>
        </div>
      </div>
    )
  }

  const fullName = `${profil.prenom} ${profil.nom}`
  const specialites = profil.specialites ? profil.specialites.split(',').map((s) => s.trim()) : []
  const qualifications = profil.qualifications ? profil.qualifications.split(',').map((s) => s.trim()) : []

  return (
    <div className="space-y-6">
      <PageHeader title="Mon Profil" />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-card rounded-[12px] border border-border p-6 text-center">
          <div className="flex justify-center">
            <UserAvatar name={fullName} size="lg" />
          </div>
          <h2 className="text-lg font-semibold text-text-main mt-4">{fullName}</h2>
          <p className="text-sm text-text-secondary">Conseiller d'orientation</p>
          {profil.actif && (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-success-light text-success mt-2">
              Actif
            </span>
          )}
        </div>

        <div className="lg:col-span-2 space-y-6">
          <div className="bg-card rounded-[12px] border border-border p-6">
            <h3 className="text-base font-semibold text-text-main mb-4">Informations générales</h3>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <Mail className="size-5 text-text-secondary shrink-0" />
                <div>
                  <p className="text-xs text-text-secondary">Email</p>
                  <p className="text-sm text-text-main">{profil.email}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <Phone className="size-5 text-text-secondary shrink-0" />
                <div>
                  <p className="text-xs text-text-secondary">Téléphone</p>
                  <p className="text-sm text-text-main">{profil.telephone || '-'}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <Calendar className="size-5 text-text-secondary shrink-0" />
                <div>
                  <p className="text-xs text-text-secondary">Membre depuis</p>
                  <p className="text-sm text-text-main">
                    {format(parseISO(profil.createdAt), 'dd MMMM yyyy', { locale: fr })}
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            <div className="bg-card rounded-[12px] border border-border p-6">
              <div className="flex items-center gap-2 mb-4">
                <Briefcase className="size-5 text-text-secondary" />
                <h3 className="text-base font-semibold text-text-main">Spécialités</h3>
              </div>
              {specialites.length > 0 ? (
                <div className="flex flex-wrap gap-2">
                  {specialites.map((s, i) => (
                    <span
                      key={i}
                      className="px-2.5 py-1 rounded-full text-xs font-medium bg-primary-light text-primary"
                    >
                      {s}
                    </span>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-text-secondary">Aucune spécialité renseignée</p>
              )}
            </div>

            <div className="bg-card rounded-[12px] border border-border p-6">
              <div className="flex items-center gap-2 mb-4">
                <Award className="size-5 text-text-secondary" />
                <h3 className="text-base font-semibold text-text-main">Qualifications</h3>
              </div>
              {qualifications.length > 0 ? (
                <ul className="space-y-2">
                  {qualifications.map((q, i) => (
                    <li key={i} className="text-sm text-text-main flex items-start gap-2">
                      <span className="text-primary mt-1">•</span>
                      {q}
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-sm text-text-secondary">Aucune qualification renseignée</p>
              )}
            </div>
          </div>

          {profil.biographie && (
            <div className="bg-card rounded-[12px] border border-border p-6">
              <div className="flex items-center gap-2 mb-4">
                <BookOpen className="size-5 text-text-secondary" />
                <h3 className="text-base font-semibold text-text-main">Biographie</h3>
              </div>
              <p className="text-sm text-text-secondary leading-relaxed">{profil.biographie}</p>
            </div>
          )}

          <div className="bg-card rounded-[12px] border border-border p-6">
            <div className="flex items-center gap-3">
              <Clock className="size-5 text-text-secondary shrink-0" />
              <div>
                <p className="text-xs text-text-secondary">Années d'expérience</p>
                <p className="text-sm text-text-main">
                  {profil.anneesExperience > 0
                    ? `${profil.anneesExperience} an${profil.anneesExperience > 1 ? 's' : ''}`
                    : 'Non renseigné'}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
