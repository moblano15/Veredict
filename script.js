// Estado de la aplicación
const appState = {
    currentUser: null,
    posts: []
};

// Elementos del DOM
const authModal = document.getElementById('auth-modal');
const authLink = document.getElementById('auth-link');
const closeModal = document.querySelector('.close-modal');
const authTabs = document.querySelectorAll('.auth-tab');
const authForms = document.querySelectorAll('.auth-form');

// Funciones de autenticación
function openAuthModal() {
    authModal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

function closeAuthModal() {
    authModal.style.display = 'none';
    document.body.style.overflow = 'auto';
}

function switchAuthTab(tabName) {
    authTabs.forEach(tab => {
        if (tab.dataset.tab === tabName) {
            tab.classList.add('active');
        } else {
            tab.classList.remove('active');
        }
    });

    authForms.forEach(form => {
        if (form.id === `${tabName}-form`) {
            form.classList.add('active');
        } else {
            form.classList.remove('active');
        }
    });
}

// Navegación entre secciones
document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault();
        
        // Remover clase active de todos los enlaces
        document.querySelectorAll('.nav-link').forEach(item => {
            item.classList.remove('active');
        });
        
        // Añadir clase active al enlace clickeado
        this.classList.add('active');
        
        // Ocultar todas las secciones
        document.querySelectorAll('.section').forEach(section => {
            section.classList.remove('active');
        });
        
        // Mostrar la sección correspondiente
        const sectionId = this.getAttribute('data-section');
        document.getElementById(sectionId).classList.add('active');
    });
});

// Búsqueda
document.getElementById('search-btn').addEventListener('click', performSearch);
document.getElementById('search-input').addEventListener('keyup', function(e) {
    if (e.key === 'Enter') {
        performSearch();
    }
});

function performSearch() {
    const query = document.getElementById('search-input').value.toLowerCase();
    const activeFilter = document.querySelector('.filter-btn.active').dataset.filter;
    
    // Aquí iría la lógica de búsqueda real con AJAX
    // Por ahora solo mostramos un mensaje
    const searchResults = document.getElementById('search-results');
    searchResults.innerHTML = `<p>Buscando: "${query}" en categoría: ${activeFilter}</p>`;
}

// Filtros de búsqueda
document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.filter-btn').forEach(item => {
            item.classList.remove('active');
        });
        this.classList.add('active');
        performSearch();
    });
});

// Event Listeners
if (authLink) {
    authLink.addEventListener('click', function(e) {
        e.preventDefault();
        openAuthModal();
    });
}

if (closeModal) {
    closeModal.addEventListener('click', closeAuthModal);
}

authTabs.forEach(tab => {
    tab.addEventListener('click', function() {
        switchAuthTab(this.dataset.tab);
    });
});

// Cerrar modal al hacer clic fuera
authModal.addEventListener('click', function(e) {
    if (e.target === authModal) {
        closeAuthModal();
    }
});

// Botón de login en perfil
const loginProfileBtn = document.getElementById('login-profile-btn');
if (loginProfileBtn) {
    loginProfileBtn.addEventListener('click', openAuthModal);
}

// Mensajes flash
setTimeout(() => {
    const messages = document.querySelectorAll('.message');
    messages.forEach(message => {
        message.style.display = 'none';
    });
}, 5000);