import { useState, useEffect } from 'react';
import { eleveService } from '../api/services';

const Parents = () => {
  const [parents, setParents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    email: '',
    motDePasse: '',
    nom: '',
    prenom: '',
    telephone: '',
    adresse: '',
    enfants: [],
  });

  useEffect(() => {
    loadParents();
  }, []);

  const loadParents = async () => {
    try {
      const data = await eleveService.getAll(0, 100);
      const parentsMap = new Map();

      (data.content || []).forEach(eleve => {
        if (eleve.parentEmail && !parentsMap.has(eleve.parentEmail)) {
          parentsMap.set(eleve.parentEmail, {
            trackingId: eleve.parentEmail,
            nom: eleve.parentNom || 'Non renseigné',
            prenom: eleve.parentPrenom || 'Non renseigné',
            email: eleve.parentEmail,
            telephone: eleve.parentTelephone || '-',
            adresse: eleve.parentAdresse || '-',
            enfants: [{ nom: eleve.nom, prenom: eleve.prenom, classe: eleve.classe }],
          });
        } else if (eleve.parentEmail) {
          const parent = parentsMap.get(eleve.parentEmail);
          parent.enfants.push({ nom: eleve.nom, prenom: eleve.prenom, classe: eleve.classe });
        }
      });

      setParents(Array.from(parentsMap.values()));
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
      loadParents();
      setFormData({
        email: '',
        motDePasse: '',
        nom: '',
        prenom: '',
        telephone: '',
        adresse: '',
        enfants: [],
      });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce parent ?')) return;
    try {
      await eleveService.delete(id);
      loadParents();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  const filteredParents = parents.filter((parent) =>
    parent.nom?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    parent.prenom?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    parent.email?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Parents</h1>
          <p className="page-subtitle">Gestion des comptes parents d'élèves</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau parent
        </button>
      </div>

      <div className="card" style={{ marginBottom: 20 }}>
        <input
          type="text"
          className="input-field"
          placeholder="Rechercher un parent..."
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
                <th>Parent</th>
                <th>Email</th>
                <th>Téléphone</th>
                <th>Enfants</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredParents.length === 0 ? (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    Aucun parent trouvé
                  </td>
                </tr>
              ) : (
                filteredParents.map((parent) => (
                  <tr key={parent.trackingId}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                        <div style={{
                          width: 40,
                          height: 40,
                          background: 'var(--accent)',
                          borderRadius: '10px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          color: 'white',
                          fontWeight: 700,
                        }}>
                          {parent.nom?.[0]}{parent.prenom?.[0]}
                        </div>
                        <div>
                          <div style={{ fontWeight: 600 }}>{parent.nom} {parent.prenom}</div>
                        </div>
                      </div>
                    </td>
                    <td>{parent.email}</td>
                    <td>{parent.telephone}</td>
                    <td>
                      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                        {parent.enfants.map((enfant, idx) => (
                          <span key={idx} className="badge badge-primary">
                            {enfant.nom} {enfant.prenom} ({enfant.classe})
                          </span>
                        ))}
                      </div>
                    </td>
                    <td>
                      <button
                        onClick={() => handleDelete(parent.trackingId)}
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
              <h3 className="modal-title">Nouveau parent</h3>
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
                  <label className="form-label">Téléphone</label>
                  <input
                    type="tel"
                    className="input-field"
                    value={formData.telephone}
                    onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
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

export default Parents;
