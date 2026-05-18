import { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const Settings = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('general');
  const [formData, setFormData] = useState({
    nom: 'Admin',
    prenom: 'Principal',
    email: 'admin@activ-education.tg',
    telephone: '',
    anciennePassword: '',
    nouveauPassword: '',
    confirmationPassword: '',
  });
  const [notifications, setNotifications] = useState({
    email: true,
    nouveauInscrit: true,
    nouveauMessage: true,
    nouveauRdv: true,
    rappelRdv: true,
  });

  const handleSave = (e) => {
    e.preventDefault();
    alert('Paramètres enregistrés avec succès !');
  };

  const handlePasswordChange = (e) => {
    e.preventDefault();
    if (formData.nouveauPassword !== formData.confirmationPassword) {
      alert('Les mots de passe ne correspondent pas');
      return;
    }
    if (formData.nouveauPassword.length < 6) {
      alert('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }
    alert('Mot de passe changé avec succès !');
    setFormData({ ...formData, anciennePassword: '', nouveauPassword: '', confirmationPassword: '' });
  };

  const handleLogout = () => {
    // Clear all authentication data (new system)
    localStorage.removeItem('user_tracking_id');
    localStorage.removeItem('user_role');
    localStorage.removeItem('auth_token'); // For cleanup
    navigate('/login');
  };

  const handleClearCache = () => {
    localStorage.clear();
    alert('Cache vidé. Vous serez redirigé vers la page de connexion.');
    navigate('/login');
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Paramètres</h1>
        <p className="page-subtitle">Configuration de l'application et du compte administrateur</p>
      </div>

      <div style={{ display: 'flex', gap: 20 }}>
        {/* Sidebar */}
        <div className="card" style={{ padding: 0, width: 250, flexShrink: 0 }}>
          <nav>
            <button
              className={`nav-item ${activeTab === 'general' ? 'active' : ''}`}
              onClick={() => setActiveTab('general')}
              style={{ width: '100%', textAlign: 'left', borderRadius: 0 }}
            >
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              <span>Général</span>
            </button>
            <button
              className={`nav-item ${activeTab === 'password' ? 'active' : ''}`}
              onClick={() => setActiveTab('password')}
              style={{ width: '100%', textAlign: 'left', borderRadius: 0 }}
            >
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
              <span>Mot de passe</span>
            </button>
            <button
              className={`nav-item ${activeTab === 'notifications' ? 'active' : ''}`}
              onClick={() => setActiveTab('notifications')}
              style={{ width: '100%', textAlign: 'left', borderRadius: 0 }}
            >
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
              </svg>
              <span>Notifications</span>
            </button>
            <button
              className={`nav-item ${activeTab === 'data' ? 'active' : ''}`}
              onClick={() => setActiveTab('data')}
              style={{ width: '100%', textAlign: 'left', borderRadius: 0, color: 'var(--error)' }}
            >
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 001.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
              <span>Données</span>
            </button>
          </nav>
        </div>

        {/* Content */}
        <div className="card" style={{ flex: 1, padding: 24 }}>
          {activeTab === 'general' && (
            <div>
              <h2 style={{ fontSize: 18, marginBottom: 20 }}>Informations du compte</h2>
              <form onSubmit={handleSave}>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
                  <div className="form-group">
                    <label className="form-label">Prénom</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.prenom}
                      onChange={(e) => setFormData({ ...formData, prenom: e.target.value })}
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Nom</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.nom}
                      onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
                    />
                  </div>
                </div>
                <div className="form-group" style={{ marginBottom: 16 }}>
                  <label className="form-label">Email</label>
                  <input
                    type="email"
                    className="input-field"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  />
                </div>
                <div className="form-group" style={{ marginBottom: 20 }}>
                  <label className="form-label">Téléphone</label>
                  <input
                    type="tel"
                    className="input-field"
                    value={formData.telephone}
                    onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
                  />
                </div>
                <button type="submit" className="btn-primary">Enregistrer</button>
              </form>
            </div>
          )}

          {activeTab === 'password' && (
            <div>
              <h2 style={{ fontSize: 18, marginBottom: 20 }}>Changer le mot de passe</h2>
              <form onSubmit={handlePasswordChange}>
                <div className="form-group" style={{ marginBottom: 16 }}>
                  <label className="form-label">Mot de passe actuel</label>
                  <input
                    type="password"
                    className="input-field"
                    value={formData.anciennePassword}
                    onChange={(e) => setFormData({ ...formData, anciennePassword: e.target.value })}
                  />
                </div>
                <div className="form-group" style={{ marginBottom: 16 }}>
                  <label className="form-label">Nouveau mot de passe</label>
                  <input
                    type="password"
                    className="input-field"
                    value={formData.nouveauPassword}
                    onChange={(e) => setFormData({ ...formData, nouveauPassword: e.target.value })}
                  />
                </div>
                <div className="form-group" style={{ marginBottom: 20 }}>
                  <label className="form-label">Confirmation</label>
                  <input
                    type="password"
                    className="input-field"
                    value={formData.confirmationPassword}
                    onChange={(e) => setFormData({ ...formData, confirmationPassword: e.target.value })}
                  />
                </div>
                <button type="submit" className="btn-primary">Changer le mot de passe</button>
              </form>
            </div>
          )}

          {activeTab === 'notifications' && (
            <div>
              <h2 style={{ fontSize: 18, marginBottom: 20 }}>Préférences de notifications</h2>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
                {Object.entries(notifications).map(([key, value]) => (
                  <div key={key} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px', background: 'var(--bg)', borderRadius: 12 }}>
                    <div>
                      <div style={{ fontWeight: 600, textTransform: 'capitalize' }}>
                        {key.replace(/([A-Z])/g, ' $1').trim()}
                      </div>
                      <div style={{ fontSize: 13, color: 'var(--text-medium)' }}>
                        Recevoir des notifications pour {key.replace(/([A-Z])/g, ' $1').toLowerCase()}
                      </div>
                    </div>
                    <button
                      onClick={() => setNotifications({ ...notifications, [key]: !value })}
                      style={{
                        width: 48,
                        height: 28,
                        background: value ? 'var(--primary)' : 'var(--text-light)',
                        borderRadius: 14,
                        position: 'relative',
                        cursor: 'pointer',
                        border: 'none',
                        transition: 'background 0.2s',
                      }}
                    >
                      <div style={{
                        width: 22,
                        height: 22,
                        background: 'white',
                        borderRadius: '50%',
                        position: 'absolute',
                        top: 3,
                        left: value ? 23 : 3,
                        transition: 'left 0.2s',
                      }} />
                    </button>
                  </div>
                ))}
              </div>
              <button className="btn-primary" style={{ marginTop: 20 }} onClick={() => alert('Préférences enregistrées !')}>
                Enregistrer
              </button>
            </div>
          )}

          {activeTab === 'data' && (
            <div>
              <h2 style={{ fontSize: 18, marginBottom: 20 }}>Gestion des données</h2>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
                <div style={{ padding: 20, background: 'var(--bg)', borderRadius: 12 }}>
                  <h3 style={{ fontSize: 16, marginBottom: 8 }}>Vider le cache</h3>
                  <p style={{ fontSize: 14, color: 'var(--text-medium)', marginBottom: 16 }}>
                    Supprime toutes les données locales stockées dans le navigateur. Vous serez déconnecté.
                  </p>
                  <button className="btn-outline" onClick={handleClearCache}>
                    Vider le cache
                  </button>
                </div>
                <div style={{ padding: 20, background: 'rgba(239, 68, 68, 0.04)', borderRadius: 12, border: '1px solid var(--error)' }}>
                  <h3 style={{ fontSize: 16, marginBottom: 8, color: 'var(--error)' }}>Déconnexion complète</h3>
                  <p style={{ fontSize: 14, color: 'var(--text-medium)', marginBottom: 16 }}>
                    Se déconnecter de tous les appareils et révoquer toutes les sessions actives.
                  </p>
                  <button className="btn-primary" style={{ background: 'var(--error)' }} onClick={handleLogout}>
                    Se déconnecter
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Settings;