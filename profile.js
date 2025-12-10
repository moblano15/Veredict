// profile.js
export function setupProfile(state) {
  const profileName = document.getElementById('profile-name');
  const profileAvatar = document.getElementById('profile-avatar');
  const userPostsContainer = document.getElementById('user-posts');

  function renderProfile() {
    if (!state.currentUser) {
      profileName.textContent = 'Inicia sesión para ver tu perfil';
      profileAvatar.src = 'https://via.placeholder.com/100';
      userPostsContainer.innerHTML = '';
      return;
    }
    profileName.textContent = state.currentUser.name;
    profileAvatar.src = state.currentUser.avatar;
    const userPosts = state.posts.filter(p => p.author === state.currentUser.name);
    if (!userPosts.length) {
      userPostsContainer.innerHTML = '<p>No has publicado ninguna opinión.</p>';
      return;
    }
    userPostsContainer.innerHTML = '';
    userPosts.forEach(post => {
      const card = document.createElement('div');
      card.classList.add('post-card');
      card.innerHTML = `
        <div class="component-tag">${post.category.toUpperCase()}</div>
        <h3>${post.title}</h3>
        <div class="rating">${'★'.repeat(post.rating) + '☆'.repeat(5 - post.rating)}</div>
        <p>${post.content}</p>
      `;
      userPostsContainer.appendChild(card);
    });
  }

  document.addEventListener('appStateChange', renderProfile);
}
