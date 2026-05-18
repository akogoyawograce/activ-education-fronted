import { useState, useEffect } from 'react';
import { rdvService } from '../api/services';

const RendezVous = () => {
  const [rdv, setRdv] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('tous');
  const [selectedRdv, setSelectedRdv] = useState(null);

  useEffect(() => {
    loadRdv();
  }, []);

  const loadRdv = async () => {
    try {
      const data = await rdvService.getAll();
      setRdv(data.content || data || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (id, statut) => {
    try {
      await rdvService.updateStatus(id, statut);
      loadRdv();
    } catch (error) {
      alert('Erreur lors de la mise à jour');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce rendez-vous ?')) return;
    try {
      await rdvService.delete(id);
      loadRdv();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  const getStatusColor = (statut) => {
    switch (statut?.toLowerCase()) {
      case 'prevu': return 'badge-primary';
      case 'confirme': return 'badge-success';
      case 'annule': return 'badge-error';
      case 'termine': return 'badge-accent';
      default: return 'badge-primary';
    }
  };

  const getStatusLabel = (statut) => {
    switch (statut?.toLowerCase()) {
      case 'prevu': return 'Prévu';
      case 'confirme': return 'Confirmé';
      case 'annule': return 'Annulé';
      case 'termine': return 'Terminé';
      default: return statut || 'Prévu';
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      weekday: 'short',
      day: 'numeric',
      month: 'long',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const filteredRdv = rdv.filter((r) => {
    if (filter === 'tous') return true;
    return r.statut?.toLowerCase() === filter;
  });

  const stats = {
    total: rdv.length,
    prevus: rdv.filter((r) => r.statut?.toLowerCase() === 'prevu').length,
    confirmes: rdv.filter((r) => r.statut?.toLowerCase() === 'confirme').length,
    termines: rdv.filter((r) => r.statut?.toLowerCase() === 'termine').length,
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Rendez-vous</h1>
          <p className="page-subtitle">Gestion des rendez-vous élèves-conseillers</p>
        </div>
      </div>

      {/* Stats */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(4, 1fr)', marginBottom: 20 }}>
        <div className="stat-card" style={{ padding: 16 }}>
          <div className="stat-value">{stats.total}</div>
          <div className="stat-label">Total RDV</div>
        </div>
        <div className="stat-card" style={{ padding: 16 }}>
          <div className="stat-value" style={{ color: 'var(--primary)' }}>{stats.prevus}</div>
          <div className="stat-label">Prévus</div>
        </div>
        <div className="stat-card" style={{ padding: 16 }}>
          <div className="stat-value" style={{ color: 'var(--success)' }}>{stats.confirmes}</div>
          <div className="stat-label">Confirmés</div>
        </div>
        <div className="stat-card" style={{ padding: 16 }}>
          <div className="stat-value" style={{ color: 'var(--accent)' }}>{stats.termines}</div>
          <div className="stat-label">Terminés</div>
        </div>
      </div>

      {/* Filters */}
      <div className="card" style={{ marginBottom: 20, padding: '12px 16px' }}>
        <div style={{ display: 'flex', gap: 8 }}>
          <button
            className={`badge ${filter === 'tous' ? 'badge-primary' : ''}`}
            onClick={() => setFilter('tous')}
            style={{ cursor: 'pointer', border: 'none', padding: '8px 16px' }}
          >
            Tous ({rdv.length})
          </button>
          <button
            className={`badge ${filter === 'prevu' ? 'badge-primary' : ''}`}
            onClick={() => setFilter('prevu')}
            style={{ cursor: 'pointer', border: 'none', padding: '8px 16px' }}
          >
            Prévus ({stats.prevus})
          </button>
          <button
            className={`badge ${filter === 'confirme' ? 'badge-success' : ''}`}
            onClick={() => setFilter('confirme')}
            style={{ cursor: 'pointer', border: 'none', padding: '8px 16px' }}
          >
            Confirmés ({stats.confirmes})
          </button>
          <button
            className={`badge ${filter === 'termine' ? 'badge-accent' : ''}`}
            onClick={() => setFilter('termine')}
            style={{ cursor: 'pointer', border: 'none', padding: '8px 16px' }}
          >
            Terminés ({stats.termines})
          </button>
        </div>
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
                <th>Conseiller</th>
                <th>Date & Heure</th>
                <th>Type</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredRdv.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    Aucun rendez-vous trouvé
                  </td>
                </tr>
              ) : (
                filteredRdv.map((r) => (
                  <tr
                    key={r.trackingId || r.id}
                    onClick={() => setSelectedRdv(r)}
                    style={{
                      cursor: 'pointer',
                      background: selectedRdv?.trackingId === r.trackingId || selectedRdv?.id === r.id ? 'rgba(61, 53, 217, 0.04)' : 'transparent',
                    }}
                  >
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div style={{
                          width: 32,
                          height: 32,
                          background: 'var(--primary)',
                          borderRadius: '8px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          color: 'white',
                          fontWeight: 600,
                          fontSize: 12,
                        }}>
                          {r.eleve?.nom?.[0] || r.elevePrenom?.[0] || '?'}
                        </div>
                        <span style={{ fontWeight: 500 }}>
                          {r.eleve?.nom ? `${r.eleve.prenom} ${r.eleve.nom}` : r.eleveNom || '-'}
                        </span>
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div style={{
                          width: 32,
                          height: 32,
                          background: 'var(--accent)',
                          borderRadius: '8px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          color: 'white',
                          fontWeight: 600,
                          fontSize: 12,
                        }}>
                          {r.conseiller?.nom?.[0] || r.conseillerNom?.[0] || '?'}
                        </div>
                        <span style={{ fontWeight: 500 }}>
                          {r.conseiller?.nom ? `${r.conseiller.prenom} ${r.conseiller.nom}` : r.conseillerNom || '-'}
                        </span>
                      </div>
                    </td>
                    <td style={{ fontWeight: 500 }}>{formatDate(r.date)}</td>
                    <td>
                      <span className="badge badge-primary">{r.type || 'En présentiel'}</span>
                    </td>
                    <td>
                      <span className={`badge ${getStatusColor(r.statut)}`}>
                        {getStatusLabel(r.statut)}
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: 4 }}>
                        {r.statut?.toLowerCase() === 'prevu' && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleStatusChange(r.trackingId || r.id, 'confirme');
                            }}
                            className="btn-outline"
                            style={{ padding: '4px 8px', fontSize: 12 }}
                            title="Confirmer"
                          >
                            ✓
                          </button>
                        )}
                        {r.statut?.toLowerCase() !== 'annule' && r.statut?.toLowerCase() !== 'termine' && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleStatusChange(r.trackingId || r.id, 'annule');
                            }}
                            style={{ color: 'var(--error)', padding: '4px 8px', borderRadius: 6, border: '1px solid var(--error)', fontSize: 12 }}
                            title="Annuler"
                          >
                            ✕
                          </button>
                        )}
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleDelete(r.trackingId || r.id);
                          }}
                          style={{ color: 'var(--text-light)', padding: '4px 8px', borderRadius: 6 }}
                          title="Supprimer"
                        >
                          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="14" height="14">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {selectedRdv && (
        <div className="card" style={{ marginTop: 20, padding: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <h2 style={{ fontSize: 18 }}>Détails du rendez-vous</h2>
            <button className="btn-outline" onClick={() => setSelectedRdv(null)}>
              Fermer
            </button>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20 }}>
            <div>
              <h3 style={{ fontSize: 14, color: 'var(--text-medium)', marginBottom: 12 }}>PARTICIPANTS</h3>
              <div style={{ padding: 16, background: 'rgba(61, 53, 217, 0.04)', borderRadius: 12, marginBottom: 12 }}>
                <div style={{ fontWeight: 600, marginBottom: 4 }}>Élève</div>
                <div>{selectedRdv.eleve?.nom ? `${selectedRdv.eleve.prenom} ${selectedRdv.eleve.nom}` : selectedRdv.eleveNom || '-'}</div>
                <div style={{ fontSize: 13, color: 'var(--text-medium)' }}>{selectedRdv.eleve?.email || selectedRdv.eleveEmail || '-'}</div>
              </div>
              <div style={{ padding: 16, background: 'rgba(255, 168, 0, 0.04)', borderRadius: 12 }}>
                <div style={{ fontWeight: 600, marginBottom: 4 }}>Conseiller</div>
                <div>{selectedRdv.conseiller?.nom ? `${selectedRdv.conseiller.prenom} ${selectedRdv.conseiller.nom}` : selectedRdv.conseillerNom || '-'}</div>
                <div style={{ fontSize: 13, color: 'var(--text-medium)' }}>{selectedRdv.conseiller?.email || selectedRdv.conseillerEmail || '-'}</div>
              </div>
            </div>
            <div>
              <h3 style={{ fontSize: 14, color: 'var(--text-medium)', marginBottom: 12 }}>INFORMATIONS</h3>
              <div style={{ padding: 16, background: 'var(--bg)', borderRadius: 12 }}>
                <div style={{ marginBottom: 12 }}>
                  <div style={{ fontSize: 13, color: 'var(--text-medium)', marginBottom: 4 }}>Date et heure</div>
                  <div style={{ fontWeight: 600 }}>{formatDate(selectedRdv.date)}</div>
                </div>
                <div style={{ marginBottom: 12 }}>
                  <div style={{ fontSize: 13, color: 'var(--text-medium)', marginBottom: 4 }}>Type</div>
                  <div>{selectedRdv.type || 'En présentiel'}</div>
                </div>
                <div style={{ marginBottom: 12 }}>
                  <div style={{ fontSize: 13, color: 'var(--text-medium)', marginBottom: 4 }}>Statut</div>
                  <span className={`badge ${getStatusColor(selectedRdv.statut)}`}>
                    {getStatusLabel(selectedRdv.statut)}
                  </span>
                </div>
                {selectedRdv.notes && (
                  <div>
                    <div style={{ fontSize: 13, color: 'var(--text-medium)', marginBottom: 4 }}>Notes</div>
                    <div>{selectedRdv.notes}</div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default RendezVous;
