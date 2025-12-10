// posts.js
export function renderPosts(posts) {
  const container = document.getElementById('posts-container');
  container.innerHTML = '';
  if (!posts.length) {
    container.innerHTML = '<p>No hay opiniones aún.</p>';
    return;
  }
  posts.forEach(post => {
    const card = document.createElement('div');
    card.classList.add('post-card');
    card.innerHTML = `
      <div class="component-tag">${post.category.toUpperCase()}</div>
      <h3>${post.title}</h3>
      <div class="rating">${'★'.repeat(post.rating) + '☆'.repeat(5 - post.rating)}</div>
      <p>${post.content}</p>
      <small>Por: ${post.author}</small>
    `;
    container.appendChild(card);
  });
}

export function renderSearchResults(posts) {
  const container = document.getElementById('search-results');
  container.innerHTML = '';
  if (!posts.length) {
    container.innerHTML = '<p>No se encontraron resultados.</p>';
    return;
  }
  posts.forEach(post => {
    const card = document.createElement('div');
    card.classList.add('post-card');
    card.innerHTML = `
      <div class="component-tag">${post.category.toUpperCase()}</div>
      <h3>${post.title}</h3>
      <div class="rating">${'★'.repeat(post.rating) + '☆'.repeat(5 - post.rating)}</div>
      <p>${post.content}</p>
      <small>Por: ${post.author}</small>
    `;
    container.appendChild(card);
  });
}
