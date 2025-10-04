// Projector Display JavaScript

// Configuration
const WEBSOCKET_URL = `ws://${window.location.hostname}:8765`;

// State
let ws = null;

// DOM Elements
const projectorContainer = document.getElementById('projectorContainer');
const projectorContent = document.getElementById('projectorContent');
const churchLogo = document.getElementById('churchLogo');
const fullscreenHint = document.getElementById('fullscreenHint');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initWebSocket();
    
    // Hide fullscreen hint after 5 seconds
    setTimeout(() => {
        fullscreenHint.style.display = 'none';
    }, 5000);
    
    // Listen for fullscreen changes
    document.addEventListener('fullscreenchange', () => {
        if (document.fullscreenElement) {
            fullscreenHint.style.display = 'none';
        }
    });
});

// WebSocket Connection
function initWebSocket() {
    try {
        ws = new WebSocket(WEBSOCKET_URL);
        
        ws.onopen = () => {
            console.log('Projector WebSocket connected');
        };
        
        ws.onclose = () => {
            console.log('Projector WebSocket disconnected');
            
            // Attempt to reconnect after 3 seconds
            setTimeout(initWebSocket, 3000);
        };
        
        ws.onerror = (error) => {
            console.error('Projector WebSocket error:', error);
        };
        
        ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                console.log('Received content:', data);
                updateDisplay(data);
            } catch (error) {
                console.error('Failed to parse message:', error);
            }
        };
        
    } catch (error) {
        console.error('Failed to create WebSocket:', error);
    }
}

// Update the display with new content
function updateDisplay(content) {
    // Handle welcome screen
    if (content.type === 'welcome_screen') {
        // Load the welcome page in an iframe
        projectorContent.innerHTML = `<iframe src="welcome.html" style="width: 100%; height: 100vh; border: none; position: fixed; top: 0; left: 0; z-index: 9999;"></iframe>`;
        churchLogo.style.display = 'none';
        return;
    }
    
    // Update font size
    projectorContent.className = 'projector-content';
    if (content.fontSize) {
        projectorContent.classList.add(`font-${content.fontSize}`);
    } else {
        projectorContent.classList.add('font-medium'); // Default
    }
    
    // Handle blank screen
    if (content.type === 'blank') {
        projectorContainer.classList.add('blank');
        projectorContent.classList.add('blank');
        churchLogo.style.display = 'none';
        return;
    } else {
        projectorContainer.classList.remove('blank');
        projectorContent.classList.remove('blank');
        churchLogo.style.display = 'block';
    }
    
    // Update text content
    if (content.text) {
        // Use innerHTML to preserve line breaks
        // Replace newlines with <br> tags for proper display
        const formattedText = content.text.replace(/\n/g, '<br>');
        projectorContent.innerHTML = formattedText;
    }
    
    // Add smooth transition effect
    projectorContent.style.opacity = '0';
    setTimeout(() => {
        projectorContent.style.transition = 'opacity 0.3s ease-in-out';
        projectorContent.style.opacity = '1';
    }, 50);
}

// Allow F11 key for fullscreen
document.addEventListener('keydown', (e) => {
    if (e.key === 'F11') {
        e.preventDefault();
        toggleFullscreen();
    }
});

// Toggle fullscreen
function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.error('Error attempting to enable fullscreen:', err);
        });
    } else {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        }
    }
}
