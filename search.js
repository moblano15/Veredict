// search.js
import { renderSearchResults } from './posts.js';

export function setupSearch(state) {
  const input = document.getElementById('search-input');
  const btn = document.getElementById('search-btn');
  const categoryButtons = document.querySelectorAll('.category-btn');

  btn.addEventListener('click', () => {
    const query = input.value.toLowerCase();
    const filtered = state.posts.filter(post =>
      post.title.toLowerCase().includes(query) || post.content.toLowerCase().includes(query)
    );
    renderSearchResults(filtered);
  });

  categoryButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      categoryButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const category = btn.dataset.category;
      let filtered = state.posts;
      if (category !== 'all') filtered = state.posts.filter(p => p.category === category);
      renderSearchResults(filtered);
    });
  });
}
