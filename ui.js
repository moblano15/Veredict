// ui.js
import { renderPosts } from './posts.js';

export function setupUI(state) {
  const navLinks = document.querySelectorAll('.nav-link');
  const sections = document.querySelectorAll('.section');
  const menuToggle = document.getElementById('menu-toggle');
  const nav = document.getElementById('main-nav');

  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const section = link.dataset.section;
      sections.forEach(s => s.classList.remove('active'));
      document.getElementById(section).classList.add('active');
      navLinks.forEach(l => l.classList.remove('active'));
      link.classList.add('active');
      if(window.innerWidth < 768) nav.classList.remove('active');
    });
  });

  menuToggle.addEventListener('click', () => nav.classList.toggle('active'));

  const form = document.getElementById('nueva-opinion');
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    if(!state.currentUser) return alert('Debes iniciar sesión para publicar.');
    const post = {
      author: state.currentUser.name,
      title: document.getElementById('titulo').value,
      content: document.getElementById('contenido').value,
      category: document.getElementById('categoria').value,
      rating: parseInt(document.getElementById('valoracion').value),
    };
    state.posts.unshift(post);
    renderPosts(state.posts);
    form.reset();
    document.dispatchEvent(new Event('appStateChange'));
    alert('Opinión publicada con éxito ✅');
  });
}
