import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../api/services';

const Login = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    trackingId: '', // Champ pour le trackingId (UUID)
    userType: 'eleves', // Par défaut, on vérifie comme élève
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // ✅ ÉTAPE CLÉ : Vérification du trackingId via l'API backend
      // Ici, formData.trackingId contient le trackingId saisi par l'utilisateur
      const data = await authService.verifyTrackingId(
        formData.trackingId.trim(),
        formData.userType
      );

      // ✅ Sauvegarde des données (pas de token !)
      authService.saveUserData(data.trackingId, formData.userType.toUpperCase());

      navigate('/dashboard');
    } catch (err) {
      // Gestion d'erreur : le trackingId n'existe pas ou mauvais type d'utilisateur
      setError(
        `Identifiant introuvable pour le type ${formData.userType}. ` +
        'Vérifiez votre trackingId et votre type d'utilisateur.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #3D35D9 0%, #2E26B0 100%)',
      padding: 20,
    }}>
      <div className="card" style={{
        width: '100%',
        maxWidth: 420,
        padding: 40,
      }}>
        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <div style={{
            width: 60,
            height: 60,
            background: 'var(--primary)',
            borderRadius: 16,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'white',
            fontSize: 24,
            fontWeight: 800,
            margin: '0 auto 16px',
          }}>
            AE
          </div>
          <h1 style={{ fontSize: 24, marginBottom: 8 }}>Activ Education</h1>
          <p style={{ color: 'var(--text-medium)' }}>Backoffice Admin</p>
        </div>

        {error && (
          <div style={{
            padding: '12px 16px',
            background: 'rgba(239, 68, 68, 0.1)',
            border: '1px solid var(--error)',
            borderRadius: 12,
            color: 'var(--error)',
            marginBottom: 20,
            fontSize: 14,
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Tracking ID (UUID)</label>
            <input
              type="text"
              className="input-field"
              placeholder="550e8400-e29b-41d4-a716-446655440000"
              value={formData.trackingId}
              onChange={(e) => setFormData({ ...formData, trackingId: e.target.value })}
              required
            />
            <small className="form-text">
              Cet identifiant vous a été fourni lors de votre inscription
            </small>
          </div>

          {/* AJOUTEZ UN SELECTEUR DE TYPE D'UTILISATEUR */}
          <div className="form-group">
            <label className="form-label">Type d'utilisateur</label>
            <select
              className="input-field"
              value={formData.userType}
              onChange={(e) => setFormData({ ...formData, userType: e.target.value })}
            >
              <option value="eleves">Élève</option>
              <option value="parents">Parent</option>
              <option value="conseillers">Conseiller</option>
              <option value="administrateurs">Administrateur</option>
            </select>
          </div>

          <button
            type="submit"
            className="btn-primary"
            style={{ width: '100%', marginTop: 8 }}
            disabled={loading}
          >
            {loading ? 'Vérification...' : 'Se connecter'}
          </button>

          <p style={{
            textAlign: 'center',
            marginTop: 24,
            fontSize: 13,
            color: 'var(--text-medium)',
          }}>
            Demo: Utilisez un trackingId valide de votre base de données
          </p>
        </form>
      </div>
    </div>
  );
};

export default Login;