import { useState, useEffect } from 'react';
import { statsService, eleveService, conseillerService } from '../api/services';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalEleves: 0,
    totalConseillers: 0,
    totalMetiers: 0,
    totalFilieres: 0,
  });
  const [loading, setLoading] = useState(true);
  const [recentActivities, setRecentActivities] = useState([]);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const data = await statsService.getDashboard();
      setStats(data);
    } catch (error) {
      console.error('Erreur chargement stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const statCards = [
    {
      title: 'Total Élèves',
      value: stats.totalEleves,
      icon: (
        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="24" height="24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
      ),
      color: 'primary',
      change: '+12% ce mois',
    },
    {
      title: 'Conseillers',
      value: stats.totalConseillers,
      icon: (
        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="24" height="24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
      ),
      color: 'success',
      change: '+2 nouveaux',
    },
    {
      title: 'Filières',
      value: stats.totalFilieres,
      icon: (
        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="24" height="24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
        </svg>
      ),
      color: 'accent',
      change: 'Catalogue complet',
    },
    {
      title: 'Métiers',
      value: stats.totalMetiers,
      icon: (
        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="24" height="24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
        </svg>
      ),
      color: 'primary',
      change: 'Base enrichie',
    },
  ];

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Dashboard</h1>
        <p className="page-subtitle">Vue d'ensemble de la plateforme Activ Education</p>
      </div>

      {loading ? (
        <div className="loading">
          <div className="spinner"></div>
        </div>
      ) : (
        <>
          {/* Stats */}
          <div className="stats-grid">
            {statCards.map((stat, index) => (
              <div key={index} className="stat-card">
                <div className="stat-header">
                  <div className={`stat-icon ${stat.color}`}>{stat.icon}</div>
                </div>
                <div className="stat-value">{stat.value}</div>
                <div className="stat-label">{stat.title}</div>
                <div className={`stat-change positive`}>{stat.change}</div>
              </div>
            ))}
          </div>

          {/* Recent Activity & Quick Actions */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: '2fr 1fr',
            gap: 20,
          }}>
            {/* Activités récentes */}
            <div className="card" style={{ padding: 24 }}>
              <h2 style={{ fontSize: 18, marginBottom: 16 }}>Activités récentes</h2>
              <div style={{ color: 'var(--text-medium)', textAlign: 'center', padding: 40 }}>
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2" width="48" height="48" style={{ margin: '0 auto 16px', opacity: 0.5 }}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                <p>Aucune activité récente</p>
              </div>
            </div>

            {/* Actions rapides */}
            <div className="card" style={{ padding: 24 }}>
              <h2 style={{ fontSize: 18, marginBottom: 16 }}>Actions rapides</h2>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                <a href="/eleves" className="btn-primary" style={{ textAlign: 'center' }}>
                  Ajouter un élève
                </a>
                <a href="/conseillers" className="btn-outline" style={{ textAlign: 'center' }}>
                  Gérer conseillers
                </a>
                <a href="/filieres" className="btn-outline" style={{ textAlign: 'center' }}>
                  Ajouter filière
                </a>
                <a href="/quiz" className="btn-outline" style={{ textAlign: 'center' }}>
                  Créer un quiz
                </a>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default Dashboard;
