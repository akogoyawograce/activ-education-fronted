import { useState, useEffect } from 'react';
import { bibliothequeService } from '../api/services';

const Etablissements = () => {
  const [etablissements, setEtablissements] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    nom: '',
    type: 'public',
    adresse: '',
    ville: '',
    telephone: '',
    email: '',
    siteWeb: '',
    serie: '',
  });
  const [series, setSeries] = useState([]);

  useEffect(() => {
    loadEtablissements();
    loadSeries();
  }, []);

  const loadEtablissements = async () => {
    try {
      const data = await bibliothequeService.getEtablissements();
      setEtablissements(data.content || data || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadSeries = async () => {
    try {
      const data = await bibliothequeService.getSeries();
      setSeries(data.content || data || []);
    } catch (error) {
      console.error('Erreur chargement séries:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await bibliothequeService.createEtablissement(formData);
      setShowModal(false);
      loadEtablissements();
      setFormData({ nom: '', type: 'public', adresse: '', ville: '', telephone: '', email: '', siteWeb: '', serie: '' });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet établissement ?')) return;
    try {
      await bibliothequeService.deleteEtablissement(id);
      loadEtablissements();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Établissements</h1>
          <p className="page-subtitle">Gestion des établissements scolaires</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouvel établissement
        </button>
      </div>

      {loading ? (
        <div className="loading">
          <div className="spinner"></div>
        </div>
      ) : (
        <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(350px, 1fr))' }}>
          {etablissements.map((etablissement) => (
            <div key={etablissement.trackingId || etablissement.id} className="card" style={{ padding: 20 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <div style={{
                    width: 48,
                    height: 48,
                    background: etablissement.type === 'prive' ? 'var(--accent)' : 'var(--primary)',
                    borderRadius: '12px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: 'white',
                    fontWeight: 700,
                    fontSize: 18,
                  }}>
                    {etablissement.nom?.[0]}
                  </div>
                  <div>
                    <h3 style={{ fontWeight: 700, fontSize: 16 }}>{etablissement.nom}</h3>
                    <span className={`badge ${etablissement.type === 'prive' ? 'badge-accent' : 'badge-primary'}`}>
                      {etablissement.type === 'prive' ? 'Privé' : 'Public'}
                    </span>
                  </div>
                </div>
                <button
                  onClick={() => handleDelete(etablissement.trackingId || etablissement.id)}
                  style={{ color: 'var(--text-light)', padding: 8, borderRadius: 8 }}
                >
                  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="18" height="18">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                </button>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8, fontSize: 13, color: 'var(--text-medium)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  {etablissement.adresse || 'Adresse non renseignée'}
                </div>
                {etablissement.ville && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 18.657A8 8 0 0116 11.85V6a1 1 0 00-1-1H9a1 1 0 00-1 1v5.85c0 2.308-1.06 4.368-2.707 5.707" />
                    </svg>
                    {etablissement.ville}
                  </div>
                )}
                {etablissement.telephone && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                    {etablissement.telephone}
                  </div>
                )}
                {etablissement.email && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                    {etablissement.email}
                  </div>
                )}
                {etablissement.serie && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                    Série: {etablissement.serie.nom || etablissement.serie}
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
              <h3 className="modal-title">Nouvel établissement</h3>
              <button onClick={() => setShowModal(false)} style={{ color: 'var(--text-medium)' }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Nom de l'établissement</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.nom}
                    onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
                    placeholder="Ex: Lycée de Tokoin, Groupe Scolaire..."
                    required
                  />
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                  <div className="form-group">
                    <label className="form-label">Type</label>
                    <select
                      className="input-field"
                      value={formData.type}
                      onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                    >
                      <option value="public">Public</option>
                      <option value="prive">Privé</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label className="form-label">Série</label>
                    <select
                      className="input-field"
                      value={formData.serie}
                      onChange={(e) => setFormData({ ...formData, serie: e.target.value })}
                    >
                      <option value="">Aucune</option>
                      {series.map((serie) => (
                        <option key={serie.trackingId || serie.id} value={serie.trackingId || serie.id}>
                          {serie.nom}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Ville</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.ville}
                    onChange={(e) => setFormData({ ...formData, ville: e.target.value })}
                    placeholder="Ex: Lomé, Kara..."
                    required
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
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
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
                    <label className="form-label">Email</label>
                    <input
                      type="email"
                      className="input-field"
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Site web</label>
                  <input
                    type="url"
                    className="input-field"
                    value={formData.siteWeb}
                    onChange={(e) => setFormData({ ...formData, siteWeb: e.target.value })}
                    placeholder="https://..."
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

export default Etablissements;
