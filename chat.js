// chat.js
export function setupChat(state) {
  const toggle = document.getElementById('chatbox-toggle');
  const chatbox = document.getElementById('chatbox');
  const closeBtn = document.getElementById('close-chatbox');
  const input = document.getElementById('chatbox-input');
  const sendBtn = document.getElementById('send-message');
  const messagesContainer = document.getElementById('chatbox-messages');

  toggle.addEventListener('click', () => chatbox.classList.toggle('active'));
  closeBtn.addEventListener('click', () => chatbox.classList.remove('active'));

  sendBtn.addEventListener('click', sendMessage);
  input.addEventListener('keypress', (e) => { if(e.key === 'Enter') sendMessage(); });

  function sendMessage() {
    const text = input.value.trim();
    if (!text) return;
    addMessage(text, 'sent');
    state.chatMessages.push({ text, type: 'sent' });
    input.value = '';
    setTimeout(() => {
      addMessage('Gracias por tu mensaje. ¡Responderemos pronto!', 'received');
      state.chatMessages.push({ text: 'Gracias por tu mensaje. ¡Responderemos pronto!', type: 'received' });
    }, 800);
  }

  function addMessage(text, type) {
    const div = document.createElement('div');
    div.classList.add('message', type);
    div.textContent = text;
    messagesContainer.appendChild(div);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }
}
