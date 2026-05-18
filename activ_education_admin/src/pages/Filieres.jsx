import { useState, useEffect } from 'react';
import { bibliothequeService } from '../api/services';

const Filieres = () => {
  const [filieres, setFilieres] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    nom: '',
    description: '',
    serie: '',
    duree: '',
    debouches: '',
  });
  const [series, setSeries] = useState([]);

  useEffect(() => {
    loadFilieres();
    loadSeries();
  }, []);

  const loadFilieres = async () => {
    try {
      const data = await bibliothequeService.getFilieres();
      setFilieres(data.content || data || []);
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
      await bibliothequeService.createFiliere(formData);
      setShowModal(false);
      loadFilieres();
      setFormData({ nom: '', description: '', serie: '', duree: '', debouches: '' });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette filière ?')) return;
    try {
      await bibliothequeService.deleteFiliere(id);
      loadFilieres();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Filières</h1>
          <p className="page-subtitle">Gestion des filières de formation</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle filière
        </button>
      </div>

      {loading ? (
        <div className="loading">
          <div className="spinner"></div>
        </div>
      ) : (
        <div className="card table-container">
          <table>
            <thead>
              <tr>
                <th>Nom</th>
                <th>Description</th>
                <th>Série</th>
                <th>Durée</th>
                <th>Débouchés</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filieres.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    Aucune filière trouvée
                  </td>
                </tr>
              ) : (
                filieres.map((filiere) => (
                  <tr key={filiere.trackingId || filiere.id}>
                    <td>
                      <span className="badge badge-accent">{filiere.nom}</span>
                    </td>
                    <td style={{ maxWidth: 300 }}>{filiere.description || '-'}</td>
                    <td>{filiere.serie?.nom || filiere.serie || '-'}</td>
                    <td>{filiere.duree || '-'}</td>
                    <td style={{ maxWidth: 200 }}>{filiere.debouches || '-'}</td>
                    <td>
                      <button
                        onClick={() => handleDelete(filiere.trackingId || filiere.id)}
                        style={{ color: 'var(--error)', padding: '8px 12px', borderRadius: 8 }}
                      >
                        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="18" height="18">
                          <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Nouvelle filière</h3>
              <button onClick={() => setShowModal(false)} style={{ color: 'var(--text-medium)' }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Nom de la filière</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.nom}
                    onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
                    placeholder="Ex: Informatique, Médecine, Droit..."
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Description</label>
                  <textarea
                    className="input-field"
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    rows="3"
                    placeholder="Description de la filière..."
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Série requise</label>
                  <select
                    className="input-field"
                    value={formData.serie}
                    onChange={(e) => setFormData({ ...formData, serie: e.target.value })}
                  >
                    <option value="">Sélectionner une série</option>
                    {series.map((serie) => (
                      <option key={serie.trackingId || serie.id} value={serie.trackingId || serie.id}>
                        {serie.nom}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="form-group">
                  <label className="form-label">Durée de formation</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.duree}
                    onChange={(e) => setFormData({ ...formData, duree: e.target.value })}
                    placeholder="Ex: 3 ans, 5 ans..."
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Débouchés professionnels</label>
                  <textarea
                    className="input-field"
                    value={formData.debouches}
                    onChange={(e) => setFormData({ ...formData, debouches: e.target.value })}
                    rows="3"
                    placeholder="Débouchés et opportunités..."
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

export default Filieres;
