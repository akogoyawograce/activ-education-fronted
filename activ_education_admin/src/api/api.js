const API_BASE_URL = 'http://localhost:8081/api/v1';

import axios from 'axios';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Plus d'intercepteur de token car l'authentification est basée sur trackingId
// Les endpoints utilisent le trackingId dans l'URL plutôt que des tokens dans les headers

// Gestion des erreurs
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Nettoyer les données d'authentification en cas d'erreur 401
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user_tracking_id');
      localStorage.removeItem('user_role');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;