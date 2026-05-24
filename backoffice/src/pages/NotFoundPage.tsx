import { useNavigate } from 'react-router-dom'
import { FileX } from 'lucide-react'

export default function NotFoundPage() {
  const navigate = useNavigate()
  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-8">
      <div className="text-center max-w-md">
        <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center mx-auto mb-5">
          <FileX className="w-8 h-8 text-primary" />
        </div>
        <h1 className="text-2xl font-bold text-text-main mb-2">Page introuvable</h1>
        <p className="text-text-secondary mb-6">La page que vous cherchez n'existe pas.</p>
        <button
          onClick={() => navigate('/login')}
          className="bg-primary hover:bg-primary-dark text-white font-medium px-5 py-2.5 rounded-lg transition-colors"
        >
          Retour à l'accueil
        </button>
      </div>
    </div>
  )
}
