import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import Layout from './components/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Eleves from './pages/Eleves';
import Conseillers from './pages/Conseillers';
import Parents from './pages/Parents';
import Series from './pages/Series';
import Filieres from './pages/Filieres';
import Metiers from './pages/Metiers';
import Etablissements from './pages/Etablissements';
import Quiz from './pages/Quiz';
import Messages from './pages/Messages';
import RendezVous from './pages/RendezVous';
import Settings from './pages/Settings';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

function PrivateRoute({ children }) {
  // Check if user is authenticated using the new system
  const isAuthenticated = localStorage.getItem('user_tracking_id') !== null;
  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />

          <Route path="/" element={<PrivateRoute><Layout /></PrivateRoute>}>
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />

            {/* Utilisateurs */}
            <Route path="eleves" element={<Eleves />} />
            <Route path="conseillers" element={<Conseillers />} />
            <Route path="parents" element={<Parents />} />

            {/* Bibliothèque */}
            <Route path="series" element={<Series />} />
            <Route path="filieres" element={<Filieres />} />
            <Route path="metiers" element={<Metiers />} />
            <Route path="etablissements" element={<Etablissements />} />

            {/* Quiz & Diagnostic */}
            <Route path="quiz" element={<Quiz />} />

            {/* Interaction */}
            <Route path="messages" element={<Messages />} />
            <Route path="rdv" element={<RendezVous />} />

            {/* Settings */}
            <Route path="settings" element={<Settings />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;