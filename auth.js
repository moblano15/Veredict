// auth.js
export function setupAuth(state) {
  const authLink = document.getElementById('auth-link');
  const avatar = document.getElementById('user-avatar');

  authLink.addEventListener('click', (e) => {
    e.preventDefault();
    if (!state.currentUser) {
      loginUser(state);
    } else {
      logoutUser(state);
    }
  });

  function loginUser(state) {
    const username = prompt('Ingresa tu nombre de usuario:');
    if (!username) return;
    state.currentUser = { name: username, avatar: `https://i.pravatar.cc/100?u=${username}` };
    authLink.textContent = 'Cerrar Sesión';
    avatar.querySelector('img').src = state.currentUser.avatar;
    alert(`Bienvenido ${username}`);
  }

  function logoutUser(state) {
    state.currentUser = null;
    authLink.textContent = 'Iniciar Sesión';
    avatar.querySelector('img').src = 'https://via.placeholder.com/40';
    alert('Has cerrado sesión');
  }
}
