/* --- 1. MOUSE GLOW & BORDER EFFECTS --- */
const light = document.getElementById('mouse-light');
const card = document.getElementById('glass-card');
const inputArea = document.querySelector('.input-area');

document.addEventListener('mousemove', (e) => {
    if (light) {
        light.style.left = e.clientX + 'px';
        light.style.top = e.clientY + 'px';
        light.style.opacity = '1';
    }
    if (card) {
        const rect = card.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        card.style.setProperty('--mouse-x', `${x}px`);
        card.style.setProperty('--mouse-y', `${y}px`);
    }
    if (inputArea) {
        const rect = inputArea.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        inputArea.style.setProperty('--input-mouse-x', `${x}px`);
        inputArea.style.setProperty('--input-mouse-y', `${y}px`);
    }
});

/* --- 2. CHAT LOGIC --- */
function handleEnter(e) {
    if (e.key === 'Enter') sendMessage();
}

async function sendMessage() {
    const inputField = document.getElementById('user-input');
    const chatBox = document.getElementById('chat-box');
    const message = inputField.value.trim();
    if (!message) return;

    chatBox.innerHTML += `<div class="message user-msg">${message}</div>`;
    inputField.value = '';
    chatBox.scrollTop = chatBox.scrollHeight;

    try {
        const loadingId = "loading-" + Date.now();
        chatBox.innerHTML += `<div class="message bot-msg" id="${loadingId}">Thinking...</div>`;
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: message })
        });
        const data = await response.json();
        document.getElementById(loadingId).remove();
        chatBox.innerHTML += `<div class="message bot-msg">${data.reply}</div>`;
        chatBox.scrollTop = chatBox.scrollHeight;
    } catch (error) {
        chatBox.innerHTML += `<div class="message bot-msg" style="color:red;">Server Error</div>`;
    }
}

/* --- 3. HISTORY LOGIC (SOLVED: PREVENTS OLD DATA) --- */
async function loadHistory() {
    const chatBox = document.getElementById('chat-box');
    
    // STEP 1: Wipe the chat box completely before loading new data
    chatBox.innerHTML = '<div class="message bot-msg">Refreshing private history...</div>';

    try {
        const response = await fetch('/api/history');
        const messages = await response.json();

        // STEP 2: Clear the "Loading" text
        chatBox.innerHTML = ''; 

        if (messages.length === 0) {
            chatBox.innerHTML = '<div class="message bot-msg">No history found for your account.</div>';
            return;
        }

        // STEP 3: Add only the messages belonging to THIS user
        messages.forEach(msg => {
            const type = (msg.sender === 'user') ? 'user-msg' : 'bot-msg';
            chatBox.innerHTML += `<div class="message ${type}">${msg.message_text}</div>`;
        });
        
        chatBox.scrollTop = chatBox.scrollHeight;
    } catch (error) {
        chatBox.innerHTML = '<div class="message bot-msg" style="color:red;">Failed to load.</div>';
    }
}