import { useState, useEffect } from 'react';
import { messageService as messagesService } from '../api/services';

const Messages = () => {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedMessage, setSelectedMessage] = useState(null);
  const [showReplyModal, setShowReplyModal] = useState(false);
  const [replyForm, setReplyForm] = useState({
    sujet: '',
    contenu: '',
    destinataire: '',
  });

  useEffect(() => {
    loadMessages();
  }, []);

  const loadMessages = async () => {
    try {
      const data = await messagesService.getAll();
      setMessages(data.content || data || []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce message ?')) return;
    try {
      await messagesService.delete(id);
      loadMessages();
    } catch (error) {
      alert('Erreur lors de la suppression');
    }
  };

  const handleReply = () => {
    if (!selectedMessage) return;
    setReplyForm({
      sujet: `Re: ${selectedMessage.sujet}`,
      contenu: '',
      destinataire: selectedMessage.expediteur?.email || selectedMessage.expediteurEmail || '',
    });
    setShowReplyModal(true);
  };

  const handleSubmitReply = async (e) => {
    e.preventDefault();
    try {
      await messagesService.create(replyForm);
      setShowReplyModal(false);
      setSelectedMessage(null);
      loadMessages();
    } catch (error) {
      alert('Erreur lors de l\'envoi');
    }
  };

  const getStatusColor = (statut) => {
    switch (statut?.toLowerCase()) {
      case 'lu': return 'badge-success';
      case 'non-lu': return 'badge-accent';
      case 'archive': return 'badge-primary';
      default: return 'badge-primary';
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Messages</h1>
          <p className="page-subtitle">Gestion des messages entre utilisateurs</p>
        </div>
        <button className="btn-primary" onClick={() => setShowReplyModal(true)}>
          <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20" style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau message
        </button>
      </div>

      {loading ? (
        <div className="loading">
          <div className="spinner"></div>
        </div>
      ) : (
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <table>
            <thead>
              <tr>
                <th style={{ width: 100 }}>Statut</th>
                <th style={{ width: 200 }}>Expéditeur</th>
                <th style={{ width: 250 }}>Sujet</th>
                <th>Contenu</th>
                <th style={{ width: 120 }}>Date</th>
                <th style={{ width: 100 }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {messages.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: 40, color: 'var(--text-medium)' }}>
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="48" height="48" style={{ margin: '0 auto 16px', opacity: 0.5 }}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
                    </svg>
                    <p>Aucun message</p>
                  </td>
                </tr>
              ) : (
                messages.map((msg) => (
                  <tr
                    key={msg.trackingId || msg.id}
                    onClick={() => setSelectedMessage(msg)}
                    style={{
                      cursor: 'pointer',
                      background: selectedMessage?.trackingId === msg.trackingId || selectedMessage?.id === msg.id ? 'rgba(61, 53, 217, 0.04)' : 'transparent',
                    }}
                  >
                    <td>
                      <span className={`badge ${getStatusColor(msg.statut)}`}>
                        {msg.statut || 'non-lu'}
                      </span>
                    </td>
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
                          {msg.expediteur?.nom?.[0] || msg.expediteur?.prenom?.[0] || '?'}
                        </div>
                        <span style={{ fontWeight: 500 }}>
                          {msg.expediteur?.nom ? `${msg.expediteur.prenom} ${msg.expediteur.nom}` : msg.expediteurEmail || 'Système'}
                        </span>
                      </div>
                    </td>
                    <td style={{ fontWeight: 600 }}>{msg.sujet || 'Sans objet'}</td>
                    <td style={{ color: 'var(--text-medium)', maxWidth: 300, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {msg.contenu?.substring(0, 80) || '-'}{msg.contenu?.length > 80 ? '...' : ''}
                    </td>
                    <td style={{ fontSize: 13, color: 'var(--text-medium)' }}>{formatDate(msg.dateEnvoi)}</td>
                    <td>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleDelete(msg.trackingId || msg.id);
                        }}
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

      {selectedMessage && (
        <div className="card" style={{ marginTop: 20, padding: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <h2 style={{ fontSize: 18 }}>{selectedMessage.sujet || 'Sans objet'}</h2>
            <div style={{ display: 'flex', gap: 8 }}>
              <button className="btn-outline" onClick={handleReply}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="16" height="16" style={{ marginRight: 8 }}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6" />
                </svg>
                Répondre
              </button>
              <button className="btn-outline" onClick={() => setSelectedMessage(null)}>
                Fermer
              </button>
            </div>
          </div>
          <div style={{
            padding: 16,
            background: 'rgba(61, 53, 217, 0.04)',
            borderRadius: 12,
            marginBottom: 16,
          }}>
            <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
              <div style={{ minWidth: 100, color: 'var(--text-medium)', fontSize: 13 }}>
                <strong>De:</strong>
              </div>
              <div>
                {selectedMessage.expediteur?.nom
                  ? `${selectedMessage.expediteur.prenom} ${selectedMessage.expediteur.nom}`
                  : selectedMessage.expediteurEmail || 'Système'}
              </div>
            </div>
            <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
              <div style={{ minWidth: 100, color: 'var(--text-medium)', fontSize: 13 }}>
                <strong>À:</strong>
              </div>
              <div>
                {selectedMessage.destinataire?.nom
                  ? `${selectedMessage.destinataire.prenom} ${selectedMessage.destinataire.nom}`
                  : selectedMessage.destinataireEmail || '-'}
              </div>
            </div>
            <div style={{ display: 'flex', gap: 12 }}>
              <div style={{ minWidth: 100, color: 'var(--text-medium)', fontSize: 13 }}>
                <strong>Date:</strong>
              </div>
              <div>{formatDate(selectedMessage.dateEnvoi)}</div>
            </div>
          </div>
          <div style={{
            padding: 20,
            background: 'var(--bg)',
            borderRadius: 12,
            lineHeight: 1.6,
          }}>
            {selectedMessage.contenu || 'Aucun contenu'}
          </div>
        </div>
      )}

      {showReplyModal && (
        <div className="modal-overlay" onClick={() => setShowReplyModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Nouveau message</h3>
              <button onClick={() => setShowReplyModal(false)} style={{ color: 'var(--text-medium)' }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSubmitReply}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Destinataire</label>
                  <input
                    type="email"
                    className="input-field"
                    value={replyForm.destinataire}
                    onChange={(e) => setReplyForm({ ...replyForm, destinataire: e.target.value })}
                    placeholder="email@exemple.com"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Sujet</label>
                  <input
                    type="text"
                    className="input-field"
                    value={replyForm.sujet}
                    onChange={(e) => setReplyForm({ ...replyForm, sujet: e.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Contenu</label>
                  <textarea
                    className="input-field"
                    value={replyForm.contenu}
                    onChange={(e) => setReplyForm({ ...replyForm, contenu: e.target.value })}
                    rows="6"
                    required
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn-outline" onClick={() => setShowReplyModal(false)}>Annuler</button>
                <button type="submit" className="btn-primary">Envoyer</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Messages;
