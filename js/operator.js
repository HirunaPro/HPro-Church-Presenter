// Operator Control JavaScript

// Configuration
const WEBSOCKET_URL = `ws://${window.location.hostname}:8765`;
const CHURCH_NAME = "Our Church"; // Configurable

// State
let ws = null;
let songs = [];
let selectedSong = null;
let currentFontSize = 'medium';
let currentContent = {
    type: 'simple_slide',
    text: `Welcome to ${CHURCH_NAME}`,
    fontSize: 'medium'
};

// DOM Elements
const connectionStatus = document.getElementById('connectionStatus');
const songSearch = document.getElementById('songSearch');
const songList = document.getElementById('songList');
const phrasesSection = document.getElementById('phrasesSection');
const currentDisplay = document.getElementById('currentDisplay');
const bibleVerseInput = document.getElementById('bibleVerse');
const showBibleVerseBtn = document.getElementById('showBibleVerse');
const addSongsBtn = document.getElementById('addSongsBtn');
const bulkImportModal = document.getElementById('bulkImportModal');
const closeModal = document.getElementById('closeModal');
const cancelImport = document.getElementById('cancelImport');
const importSongs = document.getElementById('importSongs');
const bulkSongInput = document.getElementById('bulkSongInput');
const importStatus = document.getElementById('importStatus');
const showWelcomeScreenBtn = document.getElementById('showWelcomeScreen');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initWebSocket();
    loadSongs();
    setupEventListeners();
});

// WebSocket Connection
function initWebSocket() {
    try {
        ws = new WebSocket(WEBSOCKET_URL);
        
        ws.onopen = () => {
            console.log('WebSocket connected');
            connectionStatus.textContent = 'Connected';
            connectionStatus.className = 'connection-status connected';
            
            // Send initial welcome message
            sendToProjector(currentContent);
        };
        
        ws.onclose = () => {
            console.log('WebSocket disconnected');
            connectionStatus.textContent = 'Disconnected';
            connectionStatus.className = 'connection-status disconnected';
            
            // Attempt to reconnect after 3 seconds
            setTimeout(initWebSocket, 3000);
        };
        
        ws.onerror = (error) => {
            console.error('WebSocket error:', error);
        };
        
        ws.onmessage = (event) => {
            console.log('Message from server:', event.data);
        };
        
    } catch (error) {
        console.error('Failed to create WebSocket:', error);
        connectionStatus.textContent = 'Connection Failed';
        connectionStatus.className = 'connection-status disconnected';
    }
}

// Send message to projector
function sendToProjector(content) {
    if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(content));
        currentContent = content;
        updateCurrentDisplay(content);
    } else {
        console.warn('WebSocket not connected');
    }
}

// Update current display indicator
function updateCurrentDisplay(content) {
    let displayText = '';
    
    if (content.type === 'blank') {
        displayText = 'Blank Screen';
    } else {
        displayText = content.text.substring(0, 100);
        if (content.text.length > 100) {
            displayText += '...';
        }
    }
    
    currentDisplay.textContent = displayText;
}

// Load songs from /songs directory
async function loadSongs() {
    try {
        // Get list of song files
        const response = await fetch('/songs/');
        const html = await response.text();
        
        // Parse HTML to extract .json files
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const links = doc.querySelectorAll('a');
        
        const songFiles = [];
        links.forEach(link => {
            const href = link.getAttribute('href');
            if (href && href.endsWith('.json')) {
                songFiles.push(href);
            }
        });
        
        // Load each song file
        const songPromises = songFiles.map(async (file) => {
            try {
                const res = await fetch(`/songs/${file}`);
                const song = await res.json();
                song.filename = file;
                return song;
            } catch (error) {
                console.error(`Failed to load song: ${file}`, error);
                return null;
            }
        });
        
        songs = (await Promise.all(songPromises)).filter(s => s !== null);
        songs.sort((a, b) => a.title.localeCompare(b.title));
        
        displaySongs(songs);
        
    } catch (error) {
        console.error('Failed to load songs:', error);
        songList.innerHTML = `
            <p style="text-align: center; color: #f44336; padding: 20px;">
                Failed to load songs. Make sure song files are in the /songs directory.
            </p>
        `;
    }
}

// Display songs in the list
function displaySongs(songsToDisplay) {
    if (songsToDisplay.length === 0) {
        songList.innerHTML = `
            <p style="text-align: center; color: #999; padding: 20px;">
                No songs found
            </p>
        `;
        return;
    }
    
    songList.innerHTML = '';
    songsToDisplay.forEach(song => {
        const songItem = document.createElement('div');
        songItem.className = 'song-item';
        songItem.textContent = song.title;
        songItem.addEventListener('click', () => selectSong(song));
        songList.appendChild(songItem);
    });
}

// Select a song
function selectSong(song) {
    selectedSong = song;
    
    // Update selected state in list
    document.querySelectorAll('.song-item').forEach(item => {
        item.classList.remove('selected');
        if (item.textContent === song.title) {
            item.classList.add('selected');
        }
    });
    
    // Display phrases
    displayPhrases(song);
}

// Display phrases for selected song
function displayPhrases(song) {
    phrasesSection.innerHTML = `
        <h2>${song.title}</h2>
        <div id="phrasesList"></div>
    `;
    
    const phrasesList = document.getElementById('phrasesList');
    
    song.phrases.forEach((phrase, index) => {
        const phraseItem = document.createElement('div');
        phraseItem.className = 'phrase-item';
        
        // Handle both string phrases (old format) and array phrases (new multi-line format)
        let phraseText;
        let displayText;
        
        if (Array.isArray(phrase)) {
            // New format: array of lines
            phraseText = phrase.join('\n');
            displayText = phrase.join('\n');
        } else {
            // Old format: single string
            phraseText = phrase;
            displayText = phrase;
        }
        
        // Use pre-wrap to preserve line breaks in the operator panel
        phraseItem.style.whiteSpace = 'pre-wrap';
        phraseItem.textContent = displayText;
        
        phraseItem.addEventListener('click', () => {
            // Remove active class from all phrases
            document.querySelectorAll('.phrase-item').forEach(p => {
                p.classList.remove('active');
            });
            
            // Add active class to clicked phrase
            phraseItem.classList.add('active');
            
            // Send to projector
            sendToProjector({
                type: 'song_phrase',
                text: phraseText,
                fontSize: currentFontSize,
                songTitle: song.title
            });
        });
        phrasesList.appendChild(phraseItem);
    });
}

// Setup event listeners
function setupEventListeners() {
    // Song search
    songSearch.addEventListener('input', (e) => {
        const searchTerm = e.target.value.toLowerCase();
        const filteredSongs = songs.filter(song => 
            song.title.toLowerCase().includes(searchTerm)
        );
        displaySongs(filteredSongs);
    });
    
    // Font size buttons
    document.querySelectorAll('[data-font]').forEach(btn => {
        btn.addEventListener('click', () => {
            // Remove active class from all font buttons
            document.querySelectorAll('[data-font]').forEach(b => {
                b.classList.remove('active');
            });
            
            // Add active class to clicked button
            btn.classList.add('active');
            
            // Update font size
            currentFontSize = btn.dataset.font;
            
            // Resend current content with new font size
            currentContent.fontSize = currentFontSize;
            sendToProjector(currentContent);
        });
    });
    
    // Simple slide buttons
    document.querySelectorAll('[data-slide]').forEach(btn => {
        btn.addEventListener('click', () => {
            const slideType = btn.dataset.slide;
            let content = {
                type: 'simple_slide',
                fontSize: currentFontSize
            };
            
            switch (slideType) {
                case 'welcome':
                    content.text = `Welcome to ${CHURCH_NAME}`;
                    break;
                case 'sermon':
                    content.text = 'Sermon in Progress';
                    break;
                case 'prayer':
                    content.text = 'Prayer Time';
                    break;
                case 'announcements':
                    content.text = 'Announcements';
                    break;
                case 'blank':
                    content.type = 'blank';
                    content.text = '';
                    break;
            }
            
            sendToProjector(content);
            
            // Clear active phrase
            document.querySelectorAll('.phrase-item').forEach(p => {
                p.classList.remove('active');
            });
        });
    });
    
    // Bible verse / custom text button
    showBibleVerseBtn.addEventListener('click', () => {
        const text = bibleVerseInput.value.trim();
        if (text) {
            sendToProjector({
                type: 'simple_slide',
                text: text,
                fontSize: currentFontSize
            });
            
            // Clear active phrase
            document.querySelectorAll('.phrase-item').forEach(p => {
                p.classList.remove('active');
            });
        }
    });
    
    // Welcome screen button
    showWelcomeScreenBtn.addEventListener('click', () => {
        sendToProjector({
            type: 'welcome_screen',
            text: 'Welcome Screen'
        });
        
        // Clear active phrase
        document.querySelectorAll('.phrase-item').forEach(p => {
            p.classList.remove('active');
        });
    });
    
    // Bulk import modal handlers
    addSongsBtn.addEventListener('click', () => {
        bulkImportModal.classList.add('show');
        bulkSongInput.value = '';
        importStatus.className = 'import-status';
        importStatus.textContent = '';
    });
    
    closeModal.addEventListener('click', () => {
        bulkImportModal.classList.remove('show');
    });
    
    cancelImport.addEventListener('click', () => {
        bulkImportModal.classList.remove('show');
    });
    
    // Close modal when clicking outside
    bulkImportModal.addEventListener('click', (e) => {
        if (e.target === bulkImportModal) {
            bulkImportModal.classList.remove('show');
        }
    });
    
    // Import songs button
    importSongs.addEventListener('click', async () => {
        const input = bulkSongInput.value.trim();
        if (!input) {
            showImportStatus('Please paste some songs to import.', 'error');
            return;
        }
        
        try {
            const songs = parseBulkSongs(input);
            if (songs.length === 0) {
                showImportStatus('No valid songs found. Please check the format.', 'error');
                return;
            }
            
            showImportStatus(`Processing ${songs.length} song(s)...`, 'info');
            
            // Save songs to server
            const result = await saveSongs(songs);
            
            if (result.success) {
                showImportStatus(
                    `Successfully imported ${result.saved} song(s)!${result.skipped > 0 ? ` (${result.skipped} skipped - already exist)` : ''}`,
                    'success'
                );
                
                // Reload songs after a short delay
                setTimeout(() => {
                    loadSongs();
                    bulkImportModal.classList.remove('show');
                }, 2000);
            } else {
                showImportStatus(`Error: ${result.message}`, 'error');
            }
            
        } catch (error) {
            showImportStatus(`Error: ${error.message}`, 'error');
        }
    });
}

// Parse bulk song input into structured song objects
function parseBulkSongs(input) {
    const songs = [];
    
    // Split input into lines
    const allLines = input.split('\n');
    
    let currentSong = null;
    let currentVerse = [];
    let blankLineCount = 0;
    
    for (let i = 0; i < allLines.length; i++) {
        const line = allLines[i].trim();
        
        if (line === '') {
            blankLineCount++;
            
            // If we have a current verse, save it
            if (currentVerse.length > 0 && currentSong) {
                currentSong.phrases.push([...currentVerse]);
                currentVerse = [];
            }
            
            // Two or more blank lines in a row = new song
            if (blankLineCount >= 2 && currentSong) {
                // Save the current song
                if (currentSong.phrases.length > 0) {
                    songs.push(currentSong);
                }
                currentSong = null;
            }
        } else {
            blankLineCount = 0;
            
            // Check if this is a new song (no current song and we have a line)
            if (!currentSong) {
                currentSong = {
                    title: line,
                    phrases: []
                };
            } else {
                // This is a lyric line
                currentVerse.push(line);
            }
        }
    }
    
    // Don't forget the last verse and song
    if (currentVerse.length > 0 && currentSong) {
        currentSong.phrases.push(currentVerse);
    }
    if (currentSong && currentSong.phrases.length > 0) {
        songs.push(currentSong);
    }
    
    return songs;
}

// Save songs to the server
async function saveSongs(songs) {
    try {
        const response = await fetch('/api/save-songs', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ songs: songs })
        });
        
        if (!response.ok) {
            throw new Error(`Server error: ${response.status}`);
        }
        
        return await response.json();
        
    } catch (error) {
        console.error('Error saving songs:', error);
        throw error;
    }
}

// Show import status message
function showImportStatus(message, type) {
    importStatus.textContent = message;
    importStatus.className = `import-status ${type}`;
}
