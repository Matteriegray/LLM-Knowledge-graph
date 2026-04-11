const form = document.getElementById('chatForm');
const promptInput = document.getElementById('prompt');
const chatList = document.getElementById('chatList');
const emptyState = document.getElementById('emptyState');
const messageTemplate = document.getElementById('messageTemplate');

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function formatMarkdown(text) {
  let escaped = escapeHtml(text);
  escaped = escaped.replace(/\r\n/g, '\n');
  escaped = escaped.replace(/\n{2,}/g, '\n\n');

  escaped = escaped.replace(/^######\s+(.*)$/gm, '<h6>$1</h6>');
  escaped = escaped.replace(/^#####\s+(.*)$/gm, '<h5>$1</h5>');
  escaped = escaped.replace(/^####\s+(.*)$/gm, '<h4>$1</h4>');
  escaped = escaped.replace(/^###\s+(.*)$/gm, '<h3>$1</h3>');
  escaped = escaped.replace(/^##\s+(.*)$/gm, '<h2>$1</h2>');
  escaped = escaped.replace(/^#\s+(.*)$/gm, '<h1>$1</h1>');

  escaped = escaped.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
  escaped = escaped.replace(/\*(.*?)\*/g, '<em>$1</em>');
  escaped = escaped.replace(/`{3}\n([\s\S]*?)\n`{3}/g, '<pre><code>$1</code></pre>');
  escaped = escaped.replace(/`([^`]+)`/g, '<code>$1</code>');

  escaped = escaped.replace(/^(\d+)\.\s+(.*)$/gm, '<ol-item>$2</ol-item>');
  escaped = escaped.replace(/^(?:[-*+])\s+(.*)$/gm, '<ul-item>$1</ul-item>');

  escaped = escaped.replace(/((?:<ol-item>.*<\/ol-item>\n?)+)/g, (match) => {
    const items = match.trim().split(/\n+/).map((item) => item.replace(/<ol-item>(.*)<\/ol-item>/, '<li>$1</li>')).join('');
    return `<ol>${items}</ol>`;
  });

  escaped = escaped.replace(/((?:<ul-item>.*<\/ul-item>\n?)+)/g, (match) => {
    const items = match.trim().split(/\n+/).map((item) => item.replace(/<ul-item>(.*)<\/ul-item>/, '<li>$1</li>')).join('');
    return `<ul>${items}</ul>`;
  });

  const paragraphs = escaped.split(/\n\n+/).map((block) => {
    const trimmed = block.trim();
    if (/^<h[1-6]>.*<\/h[1-6]>$/.test(trimmed) || /^<ul>/.test(trimmed) || /^<ol>/.test(trimmed) || /^<pre>/.test(trimmed)) {
      return block;
    }
    return `<p>${block.replace(/\n/g, '<br>')}</p>`;
  });

  return paragraphs.join('');
}

function addMessage(role, text) {
  emptyState.style.display = 'none';
  const node = messageTemplate.content.firstElementChild.cloneNode(true);
  node.classList.add(role === 'user' ? 'user' : 'assistant');

  const bubble = node.querySelector('.bubble');
  if (role === 'assistant') {
    bubble.innerHTML = formatMarkdown(text);
  } else {
    bubble.innerText = text;
  }

  chatList.appendChild(node);
  chatList.scrollTop = chatList.scrollHeight;
}

function setTyping(state) {
  let typingNode = document.getElementById('typingIndicator');
  if (state) {
    if (!typingNode) {
      const node = document.createElement('div');
      node.className = 'message assistant typing';
      node.id = 'typingIndicator';
      node.innerHTML = '<div class="bubble">Thinking...</div>';
      chatList.appendChild(node);
      chatList.scrollTop = chatList.scrollHeight;
    }
  } else if (typingNode) {
    typingNode.remove();
  }
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  const question = promptInput.value.trim();
  if (!question) return;

  addMessage('user', question);
  promptInput.value = '';
  promptInput.focus();
  setTyping(true);

  try {
    const response = await fetch('/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question }),
    });

    const data = await response.json();
    setTyping(false);

    if (!response.ok || data.error) {
      addMessage('assistant', data.error || 'Sorry, something went wrong.');
      return;
    }

    addMessage('assistant', data.response);
  } catch (error) {
    setTyping(false);
    addMessage('assistant', 'Network error. Please try again.');
    console.error(error);
  }
});

promptInput.addEventListener('keydown', (event) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();
    form.requestSubmit();
  }
});
