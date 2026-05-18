import { useState, useEffect } from 'react';
import { quizService } from '../api/services';

const Quiz = () => {
  const [quiz, setQuiz] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    titre: '',
    description: '',
    categorie: 'riasec',
    duree: 30,
    nombreQuestions: 0,
  });

  useEffect(() => {
    loadQuiz();
  }, []);

  const loadQuiz = async () => {
    try {
      const data = await quizService.getAll();
      setQuiz(data.content || data || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await quizService.create(formData);
      setShowModal(false);
      loadQuiz();
      setFormData({ titre: '', description: '', categorie: 'riasec', duree: 30, nombreQuestions: 0 });
    } catch (error) {
      alert('Erreur lors de la création');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce quiz ?')) return;
    try {
      await quizService.delete(id);
      loadQuiz();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  const getCategorieColor = (categorie) => {
    switch (categorie?.toLowerCase()) {
      case 'riasec': return 'badge-primary';
      case 'personnalite': return 'badge-accent';
      case 'orientation': return 'badge-success';
      default: return 'badge-primary';
    }
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Quiz</h1>
          <p className="page-subtitle">Gestion des quiz d'orientation</p>
        </div>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau quiz
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
                <th>Titre</th>
                <th>Catégorie</th>
                <th>Description</th>
                <th>Questions</th>
                <th>Durée</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {quiz.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    Aucun quiz trouvé
                  </td>
                </tr>
              ) : (
                quiz.map((q) => (
                  <tr key={q.trackingId || q.id}>
                    <td>
                      <span style={{ fontWeight: 600 }}>{q.titre}</span>
                    </td>
                    <td>
                      <span className={`badge ${getCategorieColor(q.categorie)}`}>
                        {q.categorie || 'RIASEC'}
                      </span>
                    </td>
                    <td style={{ maxWidth: 300, color: 'var(--text-medium)' }}>
                      {q.description || '-'}
                    </td>
                    <td>
                      <span className="badge badge-success">{q.nombreQuestions || 0} questions</span>
                    </td>
                    <td>{q.duree ? `${q.duree} min` : '-'}</td>
                    <td>
                      <button
                        onClick={() => handleDelete(q.trackingId || q.id)}
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
              <h3 className="modal-title">Nouveau quiz</h3>
              <button onClick={() => setShowModal(false)} style={{ color: 'var(--text-medium)' }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Titre du quiz</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.titre}
                    onChange={(e) => setFormData({ ...formData, titre: e.target.value })}
                    placeholder="Ex: Quiz d'orientation RIASEC"
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
                    placeholder="Description du quiz..."
                  />
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                  <div className="form-group">
                    <label className="form-label">Catégorie</label>
                    <select
                      className="input-field"
                      value={formData.categorie}
                      onChange={(e) => setFormData({ ...formData, categorie: e.target.value })}
                    >
                      <option value="riasec">RIASEC</option>
                      <option value="personnalite">Personnalité</option>
                      <option value="orientation">Orientation</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label className="form-label">Durée (minutes)</label>
                    <input
                      type="number"
                      className="input-field"
                      value={formData.duree}
                      onChange={(e) => setFormData({ ...formData, duree: parseInt(e.target.value) })}
                      min="1"
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

export default Quiz;
