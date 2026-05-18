import api from './api';

// ==================== AUTH (basé sur trackingId comme le Flutter) ====================
export const authService = {
  // Vérifie qu'un trackingId existe pour un type d'utilisateur donné
  verifyTrackingId: async (trackingId, userType) => {
    // userType peut être : 'eleves', 'parents', 'conseillers', 'administrateurs'
    const res = await api.get(`/${userType}/${trackingId}`);
    return res.data;
  },

  // Stocke les données utilisateur en localStorage (comme le Flutter)
  saveUserData: (trackingId, role) => {
    localStorage.setItem('user_tracking_id', trackingId);
    localStorage.setItem('user_role', role);
    // NOTE : On ne stocke PAS de token car le backend n'en génère pas
  },

  // Efface les données de connexion
  logout: () => {
    localStorage.removeItem('user_tracking_id');
    localStorage.removeItem('user_role');
    localStorage.removeItem('auth_token'); // Pour nettoyer au cas où
  },

  // Récupère l'utilisateur actuel depuis le localStorage
  getCurrentUser: () => {
    const trackingId = localStorage.getItem('user_tracking_id');
    const role = localStorage.getItem('user_role');
    return { trackingId, role };
  },

  // Vérifie si l'utilisateur est connecté
  isAuthenticated: () => {
    return !!localStorage.getItem('user_tracking_id');
  }
};

// ==================== ÉLÈVES ====================
export const eleveService = {
  getAll: async (page = 0, size = 20) => {
    const res = await api.get('/eleves', { params: { page, size } });
    return res.data;
  },

  getById: async (trackingId) => {
    const res = await api.get(`/eleves/${trackingId}`);
    return res.data;
  },

  create: async (data) => {
    const res = await api.post('/eleves', data);
    return res.data;
  },

  update: async (trackingId, data) => {
    const res = await api.put(`/eleves/${trackingId}`, data);
    return res.data;
  },

  delete: async (trackingId) => {
    await api.delete(`/eleves/${trackingId}`);
  },

  getNotes: async (trackingId) => {
    const res = await api.get(`/eleves/${trackingId}/notes`);
    return res.data;
  },
};

// ==================== CONSEILLERS ====================
export const conseillerService = {
  getAll: async (page = 0, size = 20) => {
    const res = await api.get('/conseillers', { params: { page, size } });
    return res.data;
  },

  getById: async (trackingId) => {
    const res = await api.get(`/conseillers/${trackingId}`);
    return res.data;
  },

  getDisponibles: async (seuil = 10) => {
    const res = await api.get('/conseillers/disponibles', { params: { seuil } });
    return res.data;
  },

  create: async (data) => {
    const res = await api.post('/conseillers', data);
    return res.data;
  },

  update: async (trackingId, data) => {
    const res = await api.put(`/conseillers/${trackingId}`, data);
    return res.data;
  },

  delete: async (trackingId) => {
    await api.delete(`/conseillers/${trackingId}`);
  },
};

// ==================== PARENTS ====================
export const parentService = {
  getAll: async (page = 0, size = 20) => {
    const res = await api.get('/parents', { params: { page, size } });
    return res.data;
  },

  getById: async (trackingId) => {
    const res = await api.get(`/parents/${trackingId}`);
    return res.data;
  },

  create: async (data) => {
    const res = await api.post('/parents', data);
    return res.data;
  },

  update: async (trackingId, data) => {
    const res = await api.put(`/parents/${trackingId}`, data);
    return res.data;
  },

  delete: async (trackingId) => {
    await api.delete(`/parents/${trackingId}`);
  },

  rattacherEnfant: async (parentId, eleveId) => {
    const res = await api.post(`/parents/${parentId}/enfants/${eleveId}`);
    return res.data;
  },
};

// ==================== BIBLIOTHÈQUE ====================
export const bibliothequeService = {
  // Séries
  getSeries: async (page = 0, size = 20) => {
    const res = await api.get('/bibliotheque/series', { params: { page, size } });
    return res.data;
  },

  getSerie: async (trackingId) => {
    const res = await api.get(`/bibliotheque/series/${trackingId}`);
    return res.data;
  },

  createSerie: async (data) => {
    const res = await api.post('/bibliotheque/series', data);
    return res.data;
  },

  updateSerie: async (trackingId, data) => {
    const res = await api.put(`/bibliotheque/series/${trackingId}`, data);
    return res.data;
  },

  deleteSerie: async (trackingId) => {
    await api.delete(`/bibliotheque/series/${trackingId}`);
  },

  // Filières
  getFilieres: async (page = 0, size = 20) => {
    const res = await api.get('/bibliotheque/filieres', { params: { page, size } });
    return res.data;
  },

  getFiliere: async (trackingId) => {
    const res = await api.get(`/bibliotheque/filieres/${trackingId}`);
    return res.data;
  },

  createFiliere: async (data) => {
    const res = await api.post('/bibliotheque/filieres', data);
    return res.data;
  },

  updateFiliere: async (trackingId, data) => {
    const res = await api.put(`/bibliotheque/filieres/${trackingId}`, data);
    return res.data;
  },

  deleteFiliere: async (trackingId) => {
    await api.delete(`/bibliotheque/filieres/${trackingId}`);
  },

  // Métiers
  getMetiers: async (page = 0, size = 20) => {
    const res = await api.get('/bibliotheque/metiers', { params: { page, size } });
    return res.data;
  },

  getMetier: async (trackingId) => {
    const res = await api.get(`/bibliotheque/metiers/${trackingId}`);
    return res.data;
  },

  createMetier: async (data) => {
    const res = await api.post('/bibliotheque/metiers', data);
    return res.data;
  },

  updateMetier: async (trackingId, data) => {
    const res = await api.put(`/bibliotheque/metiers/${trackingId}`, data);
    return res.data;
  },

  deleteMetier: async (trackingId) => {
    await api.delete(`/bibliotheque/metiers/${trackingId}`);
  },

  // Établissements
  getEtablissements: async (page = 0, size = 20) => {
    const res = await api.get('/bibliotheque/etablissements', { params: { page, size } });
    return res.data;
  },

  getEtablissement: async (trackingId) => {
    const res = await api.get(`/bibliotheque/etablissements/${trackingId}`);
    return res.data;
  },

  createEtablissement: async (data) => {
    const res = await api.post('/bibliotheque/etablissements', data);
    return res.data;
  },

  updateEtablissement: async (trackingId, data) => {
    const res = await api.put(`/bibliotheque/etablissements/${trackingId}`, data);
    return res.data;
  },

  deleteEtablissement: async (trackingId) => {
    await api.delete(`/bibliotheque/etablissements/${trackingId}`);
  },
};

// ==================== QUIZ ====================
export const quizService = {
  getAll: async (page = 0, size = 20) => {
    const res = await api.get('/quiz', { params: { page, size } });
    return res.data;
  },

  getById: async (trackingId) => {
    const res = await api.get(`/quiz/${trackingId}`);
    return res.data;
  },

  create: async (data) => {
    const res = await api.post('/quiz', data);
    return res.data;
  },

  update: async (trackingId, data) => {
    const res = await api.put(`/quiz/${trackingId}`, data);
    return res.data;
  },

  delete: async (trackingId) => {
    await api.delete(`/quiz/${trackingId}`);
  },

  getQuestions: async (quizId) => {
    const res = await api.get(`/quiz/${quizId}/questions`);
    return res.data;
  },

  createQuestion: async (quizId, data) => {
    const res = await api.post(`/quiz/${quizId}/questions`, data);
    return res.data;
  },

  deleteQuestion: async (questionId) => {
    await api.delete(`/questions/${questionId}`);
  },
};

// ==================== MESSAGES ====================
export const messageService = {
  getAll: async (page = 0, size = 50) => {
    const res = await api.get('/messages', { params: { page, size } });
    return res.data;
  },

  getConversation: async (user1, user2) => {
    const res = await api.get('/messages/conversation', { params: { user1, user2 } });
    return res.data;
  },

  create: async (data) => {
    const res = await api.post('/messages', data);
    return res.data;
  },

  send: async (expediteurId, data) => {
    const res = await api.post(`/utilisateurs/${expediteurId}/messages`, data);
    return res.data;
  },

  delete: async (trackingId) => {
    await api.delete(`/messages/${trackingId}`);
  },
};

// ==================== RENDEZ-VOUS ====================
export const rdvService = {
  getAll: async (page = 0, size = 20) => {
    const res = await api.get('/rendez-vous', { params: { page, size } });
    return res.data;
  },

  getByEleve: async (eleveId) => {
    const res = await api.get(`/rendez-vous/eleve/${eleveId}`);
    return res.data;
  },

  getByConseiller: async (conseillerId) => {
    const res = await api.get(`/rendez-vous/conseiller/${conseillerId}`);
    return res.data;
  },

  create: async (data) => {
    const res = await api.post('/rendez-vous', data);
    return res.data;
  },

  updateStatus: async (trackingId, statut) => {
    const res = await api.patch(`/rendez-vous/${trackingId}/statut`, { statut });
    return res.data;
  },

  annuler: async (trackingId) => {
    const res = await api.patch(`/rendez-vous/${trackingId}/annuler`);
    return res.data;
  },

  terminer: async (trackingId) => {
    const res = await api.patch(`/rendez-vous/${trackingId}/terminer`);
    return res.data;
  },

  delete: async (trackingId) => {
    await api.delete(`/rendez-vous/${trackingId}`);
  },
};

// ==================== STATISTIQUES ====================
export const statsService = {
  getDashboard: async () => {
    // TODO: Créer un endpoint dédié pour les stats dashboard
    const [eleves, conseillers, metiers, filieres] = await Promise.all([
      api.get('/eleves', { params: { page: 0, size: 1 } }),
      api.get('/conseillers', { params: { page: 0, size: 1 } }),
      api.get('/bibliotheque/metiers', { params: { page: 0, size: 1 } }),
      api.get('/bibliotheque/filieres', { params: { page: 0, size: 1 } }),
    ]);

    return {
      totalEleves: eleves.data.totalElements,
      totalConseillers: conseillers.data.totalElements,
      totalMetiers: metiers.data.totalElements,
      totalFilieres: filieres.data.totalElements,
    };
  },
};