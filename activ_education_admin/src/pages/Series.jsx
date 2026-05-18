import { useState, useEffect } from 'react';
import { bibliothequeService } from '../api/services';

const Series = () => {
  const [series, setSeries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    nom: '',
    description: '',
    ordre: 1,
  });

  useEffect(() => {
    loadSeries();
  }, []);

  const loadSeries = async () => {
    try {
      const data = await bibliothequeService.getSeries();
      setSeries(data.content || data || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await bibliothequeService.createSeries(formData);
      setShowModal(false);
      loadSeries();
      setFormData({ nom: '', description: '', ordre: 1 });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette série ?')) return;
    try {
      await bibliothequeService.deleteSeries(id);
      loadSeries();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Séries</h1>
          <p className="page-subtitle">Gestion des séries scolaires</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle série
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
                <th>Ordre</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {series.length === 0 ? (
                <tr>
                  <td colSpan="4" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    Aucune série trouvée
                  </td>
                </tr>
              ) : (
                series.map((serie) => (
                  <tr key={serie.trackingId || serie.id}>
                    <td>
                      <span className="badge badge-primary">{serie.nom}</span>
                    </td>
                    <td>{serie.description || '-'}</td>
                    <td>{serie.ordre || '-'}</td>
                    <td>
                      <button
                        onClick={() => handleDelete(serie.trackingId || serie.id)}
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
              <h3 className="modal-title">Nouvelle série</h3>
              <button onClick={() => setShowModal(false)} style={{ color: 'var(--text-medium)' }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Nom de la série</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.nom}
                    onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
                    placeholder="Ex: Série C, Série D, Série A..."
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
                    placeholder="Description de la série..."
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Ordre d'affichage</label>
                  <input
                    type="number"
                    className="input-field"
                    value={formData.ordre}
                    onChange={(e) => setFormData({ ...formData, ordre: parseInt(e.target.value) })}
                    min="1"
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

export default Series;
