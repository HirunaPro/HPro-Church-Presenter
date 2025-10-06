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
const nextVersePreview = document.getElementById('nextVersePreview');
const songTitleDisplay = document.getElementById('songTitleDisplay');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Show welcome screen by default
    showWelcomeScreen();
    
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

// Show welcome screen
function showWelcomeScreen() {
    // Fade out current content first
    projectorContent.classList.add('fade-out');
    
    setTimeout(() => {
        // Add timestamp to prevent caching
        const timestamp = new Date().getTime();
        const iframe = document.createElement('iframe');
        iframe.src = `welcome.html?v=${timestamp}`;
        iframe.style.cssText = 'width: 100%; height: 100vh; border: none; position: fixed; top: 0; left: 0; z-index: 9999; opacity: 0; transition: opacity 0.5s ease-in-out;';
        
        // Clear existing content and add new iframe
        projectorContent.innerHTML = '';
        projectorContent.appendChild(iframe);
        
        churchLogo.style.display = 'none';
        
        // Fade in iframe after load
        iframe.onload = () => {
            iframe.style.opacity = '1';
        };
        
        // Fade in immediately if load event doesn't fire
        setTimeout(() => {
            iframe.style.opacity = '1';
        }, 100);
    }, 500);
}

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
        // Fade out current content
        projectorContent.classList.add('fade-out');
        
        setTimeout(() => {
            // Load the welcome page in an iframe with cache busting
            const timestamp = new Date().getTime();
            const iframe = document.createElement('iframe');
            iframe.src = `welcome.html?v=${timestamp}`;
            iframe.style.cssText = 'width: 100%; height: 100vh; border: none; position: fixed; top: 0; left: 0; z-index: 9999; opacity: 0; transition: opacity 0.5s ease-in-out;';
            
            // Clear existing content and add new iframe
            projectorContent.innerHTML = '';
            projectorContent.appendChild(iframe);
            
            churchLogo.style.display = 'none';
            
            // Hide next verse preview for welcome screen
            nextVersePreview.classList.remove('visible');
            
            // Hide song title for welcome screen
            songTitleDisplay.classList.remove('visible');
            
            // Fade in iframe after load
            iframe.onload = () => {
                iframe.style.opacity = '1';
            };
            
            // Fade in immediately if load event doesn't fire
            setTimeout(() => {
                iframe.style.opacity = '1';
            }, 100);
        }, 500);
        
        return;
    }
    
    // Update font size class
    const newFontClass = content.fontSize ? `font-${content.fontSize}` : 'font-medium';
    const isAutoFont = content.fontSize === 'auto';
    
    // Handle blank screen
    if (content.type === 'blank') {
        // Fade out before going blank
        projectorContent.classList.add('fade-out');
        
        setTimeout(() => {
            projectorContainer.classList.add('blank');
            projectorContent.classList.add('blank');
            churchLogo.style.display = 'none';
            
            // Hide next verse preview for blank screen
            nextVersePreview.classList.remove('visible');
            
            // Hide song title for blank screen
            songTitleDisplay.classList.remove('visible');
        }, 500); // Wait for fade out
        
        return;
    } else {
        projectorContainer.classList.remove('blank');
        projectorContent.classList.remove('blank');
        churchLogo.style.display = 'block';
    }
    
    // Fade transition sequence for content changes
    // Step 1: Fade out current content
    projectorContent.classList.add('fade-out');
    projectorContent.classList.remove('fade-in');
    
    // Step 2: After fade out completes, update content
    setTimeout(() => {
        // Update text content
        if (content.text) {
            // Use innerHTML to preserve line breaks
            // Replace newlines with <br> tags for proper display
            const formattedText = content.text.replace(/\n/g, '<br>');
            projectorContent.innerHTML = formattedText;
        }
        
        // Update font size
        projectorContent.className = 'projector-content';
        projectorContent.classList.add(newFontClass);
        
        // If auto font size, calculate optimal size
        if (isAutoFont) {
            calculateAutoFontSize();
        }
        
        // Handle next verse preview
        if (content.nextVersePreview) {
            nextVersePreview.textContent = content.nextVersePreview;
            // Delay preview appearance slightly
            setTimeout(() => {
                nextVersePreview.classList.add('visible');
            }, 300);
        } else {
            nextVersePreview.classList.remove('visible');
        }
        
        // Handle song title display
        if (content.songTitle && content.type === 'song_phrase') {
            songTitleDisplay.textContent = content.songTitle;
            // Delay title appearance slightly
            setTimeout(() => {
                songTitleDisplay.classList.add('visible');
            }, 300);
        } else {
            songTitleDisplay.classList.remove('visible');
        }
        
        // Step 3: Fade in new content
        setTimeout(() => {
            projectorContent.classList.remove('fade-out');
            projectorContent.classList.add('fade-in');
        }, 50); // Small delay before fade in
        
    }, 500); // Duration matches fade-out transition (0.5s)
}

// Calculate and apply the optimal font size for auto mode
function calculateAutoFontSize() {
    // Get the container dimensions
    const containerWidth = projectorContainer.clientWidth;
    const containerHeight = projectorContainer.clientHeight;
    
    // Calculate actual available space
    // Account for song title if visible
    const songTitleHeight = songTitleDisplay.classList.contains('visible') ? 
        songTitleDisplay.offsetHeight + 20 : 0;
    
    // Account for next verse preview if visible
    const nextVerseHeight = nextVersePreview.classList.contains('visible') ? 
        nextVersePreview.offsetHeight + 20 : 0;
    
    // Account for church logo
    const logoHeight = churchLogo.style.display !== 'none' ? 100 : 0;
    
    // More generous padding to prevent cropping
    const paddingHorizontal = 100; // Left and right padding combined
    const paddingVertical = 80; // Top and bottom padding
    
    const availableWidth = containerWidth - paddingHorizontal;
    const availableHeight = containerHeight - songTitleHeight - nextVerseHeight - logoHeight - paddingVertical;
    
    // Start with a large font size and reduce until it fits
    let minFontSize = 20;
    let maxFontSize = 250;
    let bestFontSize = minFontSize;
    
    // Create a temporary element to measure text
    const tempElement = document.createElement('div');
    tempElement.style.cssText = `
        position: absolute;
        visibility: hidden;
        white-space: nowrap;
        display: inline-block;
        padding: 0;
        margin: 0;
    `;
    tempElement.innerHTML = projectorContent.innerHTML;
    document.body.appendChild(tempElement);
    
    // Binary search for the optimal font size
    while (maxFontSize - minFontSize > 1) {
        const fontSize = Math.floor((minFontSize + maxFontSize) / 2);
        tempElement.style.fontSize = fontSize + 'px';
        tempElement.style.lineHeight = '1.2';
        
        const textWidth = tempElement.offsetWidth;
        const textHeight = tempElement.offsetHeight;
        
        // Add small buffer to prevent edge cropping
        if (textWidth <= availableWidth * 0.95 && textHeight <= availableHeight * 0.95) {
            bestFontSize = fontSize;
            minFontSize = fontSize;
        } else {
            maxFontSize = fontSize;
        }
    }
    
    // Clean up
    document.body.removeChild(tempElement);
    
    // Apply the calculated font size with inline styles
    projectorContent.style.fontSize = bestFontSize + 'px';
    projectorContent.style.lineHeight = '1.2';
    
    console.log('Auto font size:', bestFontSize, 'px', 
                'Available space:', availableWidth, 'x', availableHeight);
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
