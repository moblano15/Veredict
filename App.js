import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import Home from './pages/Home';
import Search from './pages/Search';
import Create from './pages/Create';
import Profile from './pages/Profile';
import AuthModal from './components/AuthModal';
import Chatbox from './components/Chatbox';
import './styles.css';

function App() {
  const [activeSection, setActiveSection] = useState('inicio');
  const [currentUser, setCurrentUser] = useState(null);
  const [showAuthModal, setShowAuthModal] = useState(false);
  
  // Cargar usuario de localStorage al iniciar
  useEffect(() => {
    const savedUser = localStorage.getItem('veredict_user');
    if (savedUser) {
      try {
        setCurrentUser(JSON.parse(savedUser));
      } catch (e) {
        console.error('Error al cargar usuario:', e);
      }
    }
  }, []);
  
  const handleLogin = (user) => {
    setCurrentUser(user);
    localStorage.setItem('veredict_user', JSON.stringify(user));
    setShowAuthModal(false);
    setActiveSection('inicio');
  };
  
  const handleLogout = () => {
    setCurrentUser(null);
    localStorage.removeItem('veredict_user');
    setActiveSection('inicio');
  };
  
  const handleNavigation = (section) => {
    if (section === 'auth') {
      setShowAuthModal(true);
    } else {
      setActiveSection(section);
    }
  };
  
  const renderSection = () => {
    switch(activeSection) {
      case 'inicio':
        return <Home currentUser={currentUser} />;
      case 'busqueda':
        return <Search currentUser={currentUser} />;
      case 'crear':
        return <Create currentUser={currentUser} />;
      case 'perfil':
        return <Profile currentUser={currentUser} />;
      default:
        return <Home currentUser={currentUser} />;
    }
  };

  return (
    <div className="App">
      <Header 
        currentUser={currentUser}
        onLogout={handleLogout}
        onNavigate={handleNavigation}
        activeSection={activeSection}
      />
      
      <main>
        <div className="container">
          {renderSection()}
        </div>
      </main>
      
      {showAuthModal && (
        <AuthModal 
          onClose={() => setShowAuthModal(false)}
          onLogin={handleLogin}
        />
      )}
      
      <Chatbox />
      
      <footer>
        <div className="container">
          <p>Veredict - Tu red social de reviews sobre componentes de ordenador &copy; 2025</p>
          <p style={{ fontSize: '12px', opacity: 0.8 }}>Powered by Google Gemini AI</p>
        </div>
      </footer>
    </div>
  );
}

export default App;