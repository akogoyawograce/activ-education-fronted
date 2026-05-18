import { useState, useEffect } from 'react';
import { eleveService } from '../api/services';

const Eleves = () => {
  const [eleves, setEleves] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    email: '',
    motDePasse: '',
    nom: '',
    prenom: '',
    dateNaissance: '',
    sexe: 'M',
    telephone: '',
    adresse: '',
    etablissement: '',
    classe: '',
  });

  useEffect(() => {
    loadEleves();
  }, []);

  const loadEleves = async () => {
    try {
      const data = await eleveService.getAll(0, 100);
      setEleves(data.content || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await eleveService.create(formData);
      setShowModal(false);
      loadEleves();
      setFormData({
        email: '',
        motDePasse: '',
        nom: '',
        prenom: '',
        dateNaissance: '',
        sexe: 'M',
        telephone: '',
        adresse: '',
        etablissement: '',
        classe: '',
      });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet élève ?')) return;
    try {
      await eleveService.delete(id);
      loadEleves();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  const filteredEleves = eleves.filter((eleve) =>
    eleve.nom?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    eleve.prenom?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    eleve.email?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Élèves</h1>
          <p className="page-subtitle">Gestion des comptes élèves</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouvel élève
        </button>
      </div>

      <div className="card" style={{ marginBottom: 20 }}>
        <input
          type="text"
          className="input-field"
          placeholder="Rechercher un élève..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          style={{ border: 'none', boxShadow: 'none' }}
        />
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
                <th>Élève</th>
                <th>Email</th>
                <th>Classe</th>
                <th>Établissement</th>
                <th>Date naissance</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredEleves.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    Aucun élève trouvé
                  </td>
                </tr>
              ) : (
                filteredEleves.map((eleve) => (
                  <tr key={eleve.trackingId}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                        <div style={{
                          width: 40,
                          height: 40,
                          background: 'var(--primary)',
                          borderRadius: '10px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          color: 'white',
                          fontWeight: 700,
                        }}>
                          {eleve.nom?.[0]}{eleve.prenom?.[0]}
                        </div>
                        <div>
                          <div style={{ fontWeight: 600 }}>{eleve.nom} {eleve.prenom}</div>
                        </div>
                      </div>
                    </td>
                    <td>{eleve.email}</td>
                    <td><span className="badge badge-primary">{eleve.classe}</span></td>
                    <td>{eleve.etablissement || '-'}</td>
                    <td>{eleve.dateNaissance ? new Date(eleve.dateNaissance).toLocaleDateString('fr-FR') : '-'}</td>
                    <td>
                      <button
                        onClick={() => handleDelete(eleve.trackingId)}
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
              <h3 className="modal-title">Nouvel élève</h3>
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
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                  <div className="form-group">
                    <label className="form-label">Date de naissance</label>
                    <input
                      type="date"
                      className="input-field"
                      value={formData.dateNaissance}
                      onChange={(e) => setFormData({ ...formData, dateNaissance: e.target.value })}
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Sexe</label>
                    <select
                      className="input-field"
                      value={formData.sexe}
                      onChange={(e) => setFormData({ ...formData, sexe: e.target.value })}
                    >
                      <option value="M">Masculin</option>
                      <option value="F">Féminin</option>
                    </select>
                  </div>
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
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                  <div className="form-group">
                    <label className="form-label">Établissement</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.etablissement}
                      onChange={(e) => setFormData({ ...formData, etablissement: e.target.value })}
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Classe</label>
                    <input
                      type="text"
                      className="input-field"
                      value={formData.classe}
                      onChange={(e) => setFormData({ ...formData, classe: e.target.value })}
                      placeholder="Ex: Terminale C"
                    />
                  </div>
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

export default Eleves;
