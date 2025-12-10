import { renderPosts, renderSearchResults } from './posts.js';
import { setupAuth } from './auth.js';
import { setupSearch } from './search.js';
import { setupProfile } from './profile.js';
import { setupChat } from './chat.js';
import { setupUI } from './ui.js';

export const appState = {
  currentUser: null,
  posts: [], 
  users: [],
  chatMessages: []
};

document.addEventListener('DOMContentLoaded', () => {
  setupUI(appState);
  setupAuth(appState);
  setupSearch(appState);
  setupProfile(appState);
  setupChat(appState);
  renderPosts(appState.posts);
  renderSearchResults(appState.posts);
});
