import { useState, useEffect } from 'react';
import { bibliothequeService } from '../api/services';

const Metiers = () => {
  const [metiers, setMetiers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    nom: '',
    description: '',
    salaire: '',
    etudes: '',
    competences: '',
    filiere: '',
  });
  const [filieres, setFilieres] = useState([]);

  useEffect(() => {
    loadMetiers();
    loadFilieres();
  }, []);

  const loadMetiers = async () => {
    try {
      const data = await bibliothequeService.getMetiers();
      setMetiers(data.content || data || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadFilieres = async () => {
    try {
      const data = await bibliothequeService.getFilieres();
      setFilieres(data.content || data || []);
    } catch (error) {
      console.error('Erreur chargement filières:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await bibliothequeService.createMetier(formData);
      setShowModal(false);
      loadMetiers();
      setFormData({ nom: '', description: '', salaire: '', etudes: '', competences: '', filiere: '' });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce métier ?')) return;
    try {
      await bibliothequeService.deleteMetier(id);
      loadMetiers();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Métiers</h1>
          <p className="page-subtitle">Gestion des métiers et professions</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau métier
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
                <th>Salaire</th>
                <th>Études</th>
                <th>Filière</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {metiers.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    Aucun métier trouvé
                  </td>
                </tr>
              ) : (
                metiers.map((metier) => (
                  <tr key={metier.trackingId || metier.id}>
                    <td>
                      <span className="badge badge-success">{metier.nom}</span>
                    </td>
                    <td style={{ maxWidth: 300 }}>{metier.description || '-'}</td>
                    <td>{metier.salaire || '-'}</td>
                    <td>{metier.etudes || '-'}</td>
                    <td>{metier.filiere?.nom || metier.filiere || '-'}</td>
                    <td>
                      <button
                        onClick={() => handleDelete(metier.trackingId || metier.id)}
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
              <h3 className="modal-title">Nouveau métier</h3>
              <button onClick={() => setShowModal(false)} style={{ color: 'var(--text-medium)' }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Nom du métier</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.nom}
                    onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
                    placeholder="Ex: Développeur Web, Médecin, Avocat..."
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
                    placeholder="Description du métier..."
                  />
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                  <div className="form-group">
                    <label className="form-label">Salaire moyen</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.salaire}
                      onChange={(e) => setFormData({ ...formData, salaire: e.target.value })}
                      placeholder="Ex: 1500-3000€"
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Durée des études</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.etudes}
                      onChange={(e) => setFormData({ ...formData, etudes: e.target.value })}
                      placeholder="Ex: Bac+3, Bac+5..."
                    />
                  </div>
                </div>
                <div className="form-group">
                  <label className="form-label">Compétences requises</label>
                  <textarea
                    className="input-field"
                    value={formData.competences}
                    onChange={(e) => setFormData({ ...formData, competences: e.target.value })}
                    rows="3"
                    placeholder="Compétences et savoir-faire..."
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Filière associée</label>
                  <select
                    className="input-field"
                    value={formData.filiere}
                    onChange={(e) => setFormData({ ...formData, filiere: e.target.value })}
                  >
                    <option value="">Sélectionner une filière</option>
                    {filieres.map((filiere) => (
                      <option key={filiere.trackingId || filiere.id} value={filiere.trackingId || filiere.id}>
                        {filiere.nom}
                      </option>
                    ))}
                  </select>
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

export default Metiers;
