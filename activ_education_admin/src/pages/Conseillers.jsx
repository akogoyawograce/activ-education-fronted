import { useState, useEffect } from 'react';
import { conseillerService } from '../api/services';

const Conseillers = () => {
  const [conseillers, setConseillers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    motDePasse: '',
    nom: '',
    prenom: '',
    telephone: '',
    adresse: '',
    specialite: '',
    bio: '',
  });

  useEffect(() => {
    loadConseillers();
  }, []);

  const loadConseillers = async () => {
    try {
      const data = await conseillerService.getAll(0, 100);
      setConseillers(data.content || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await conseillerService.create(formData);
      setShowModal(false);
      loadConseillers();
      setFormData({
        email: '',
        motDePasse: '',
        nom: '',
        prenom: '',
        telephone: '',
        adresse: '',
        specialite: '',
        bio: '',
      });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce conseiller ?')) return;
    try {
      await conseillerService.delete(id);
      loadConseillers();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Conseillers</h1>
          <p className="page-subtitle">Gestion des conseillers d'orientation</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau conseiller
        </button>
      </div>

      {loading ? (
        <div className="loading">
          <div className="spinner"></div>
        </div>
      ) : (
        <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))' }}>
          {conseillers.map((conseiller) => (
            <div key={conseiller.trackingId} className="card" style={{ padding: 20 }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 16 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <div style={{
                    width: 56,
                    height: 56,
                    background: 'var(--primary)',
                    borderRadius: '14px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: 'white',
                    fontWeight: 700,
                    fontSize: 20,
                  }}>
                    {conseiller.nom?.[0]}{conseiller.prenom?.[0]}
                  </div>
                  <div>
                    <h3 style={{ fontWeight: 700 }}>{conseiller.nom} {conseiller.prenom}</h3>
                    <p style={{ color: 'var(--text-medium)', fontSize: 13 }}>{conseiller.specialite || 'Conseiller'}</p>
                  </div>
                </div>
                <button
                  onClick={() => handleDelete(conseiller.trackingId)}
                  style={{ color: 'var(--text-light)', padding: 8, borderRadius: 8 }}
                >
                  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="18" height="18">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                </button>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: 'var(--text-medium)', fontSize: 13 }}>
                  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  {conseiller.email}
                </div>
                {conseiller.telephone && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: 'var(--text-medium)', fontSize: 13 }}>
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                    {conseiller.telephone}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Nouveau conseiller</h3>
              <button onClick={() => setShowModal(false)} style={{ color: 'var(--text-medium)' }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Email</label>
                  <input
                    type="email"
                    className="input-field"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Mot de passe</label>
                  <input
                    type="password"
                    className="input-field"
                    value={formData.motDePasse}
                    onChange={(e) => setFormData({ ...formData, motDePasse: e.target.value })}
                    required
                  />
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                  <div className="form-group">
                    <label className="form-label">Nom</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.nom}
                      onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Prénom</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.prenom}
                      onChange={(e) => setFormData({ ...formData, prenom: e.target.value })}
                      required
                    />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Spécialité</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.specialite}
                    onChange={(e) => setFormData({ ...formData, specialite: e.target.value })}
                    placeholder="Ex: Orientation scolaire, Reconversion..."
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Téléphone</label>
                  <input
                    type="tel"
                    className="input-field"
                    value={formData.telephone}
                    onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Adresse</label>
                  <textarea
                    className="input-field"
                    value={formData.adresse}
                    onChange={(e) => setFormData({ ...formData, adresse: e.target.value })}
                    rows="2"
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Bio</label>
                  <textarea
                    className="input-field"
                    value={formData.bio}
                    onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                    rows="3"
                    placeholder="Présentation du conseiller..."
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn-outline" onClick={() => setShowModal(false)}>Annuler</button>
                <button type="submit" className="btn-primary">Créer</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Conseillers;
