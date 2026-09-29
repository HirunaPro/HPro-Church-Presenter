// Operator Control JavaScript

// Configuration
const DEFAULT_WS_PORT = 8765;
const OPERATOR_KEY_STORAGE = 'operatorKey';
const CHURCH_NAME = "Our Church"; // Configurable

// State
let ws = null;
let songs = [];
let selectedSong = null;
let activePhraseIndex = -1;
let currentFontSize = 'medium';
let currentContent = {
    type: 'simple_slide',
    text: `Welcome to ${CHURCH_NAME}`,
    fontSize: 'medium'
};

// DOM Elements
const connectionStatus = document.getElementById('connectionStatus');
const songSearch = document.getElementById('songSearch');
const searchClearBtn = document.getElementById('searchClearBtn');
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
const blankQuickBtn = document.getElementById('blankQuickBtn');
const prevPhraseBtn = document.getElementById('prevPhraseBtn');
const nextPhraseBtn = document.getElementById('nextPhraseBtn');
const phrasePosition = document.getElementById('phrasePosition');
const openSongsBtn = document.getElementById('openSongsBtn');
const sheetHandle = document.getElementById('sheetHandle');
const operatorSidebar = document.getElementById('operatorSidebar');
const mobileMenuOverlay = document.getElementById('mobileMenuOverlay');
const selectedSongInfo = document.getElementById('selectedSongInfo');
const selectedSongTitle = document.getElementById('selectedSongTitle');
const clearSelectionBtn = document.getElementById('clearSelection');
const bibleVerseTabInput = document.getElementById('bibleVerseTab');
const showBibleVerseTabBtn = document.getElementById('showBibleVerseTab');

// Export/Import elements
const exportSongsBtn = document.getElementById('exportSongsBtn');
const importSongsBtn = document.getElementById('importSongsBtn');

// Edit song modal elements
const editSongModal = document.getElementById('editSongModal');
const closeEditModal = document.getElementById('closeEditModal');
const cancelEdit = document.getElementById('cancelEdit');
const editSongTitle = document.getElementById('editSongTitle');
const editSongContent = document.getElementById('editSongContent');
const saveSongEdit = document.getElementById('saveSongEdit');
const deleteSongBtn = document.getElementById('deleteSongBtn');
const editStatus = document.getElementById('editStatus');

let currentEditingSong = null;

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initWebSocket();
    loadSongs();
    setupEventListeners();
});

// Server config and operator auth
let serverConfig = null;

async function getServerConfig() {
    if (serverConfig) return serverConfig;
    let config = { wsPort: DEFAULT_WS_PORT, authRequired: false };
    try {
        const res = await fetch('/api/config');
        if (res.ok) {
            const data = await res.json();
            config = {
                wsPort: data.wsPort || DEFAULT_WS_PORT,
                authRequired: !!data.authRequired
            };
            serverConfig = config;
        }
    } catch (error) {
        console.warn('Failed to load config, using defaults:', error);
    }
    return config;
}

function promptForOperatorKey() {
    const key = (window.prompt('Enter operator key:') || '').trim();
    if (key) {
        localStorage.setItem(OPERATOR_KEY_STORAGE, key);
    }
    return key;
}

function getOperatorKey() {
    return localStorage.getItem(OPERATOR_KEY_STORAGE) || '';
}

async function ensureOperatorKey() {
    const config = await getServerConfig();
    if (!config.authRequired) return '';
    return getOperatorKey() || promptForOperatorKey();
}

async function getWebSocketUrl() {
    const config = await getServerConfig();
    const scheme = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    let url = `${scheme}//${window.location.hostname}:${config.wsPort}`;
    const key = await ensureOperatorKey();
    if (key) {
        url += `?key=${encodeURIComponent(key)}`;
    }
    return url;
}

// POST JSON to the API with operator auth; throws Error with the server message on failure
async function apiPost(url, payload) {
    const headers = { 'Content-Type': 'application/json' };
    const key = await ensureOperatorKey();
    if (key) {
        headers['X-Operator-Key'] = key;
    }
    
    const response = await fetch(url, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify(payload)
    });
    
    if (response.status === 401) {
        localStorage.removeItem(OPERATOR_KEY_STORAGE);
        promptForOperatorKey();
        if (ws) ws.close();
        throw new Error('Unauthorized: invalid or missing operator key. Please try again.');
    }
    
    if (!response.ok) {
        let message = `Server error: ${response.status}`;
        try {
            const data = await response.json();
            if (data && data.message) message = data.message;
        } catch (e) {
            // Non-JSON error body; keep generic message
        }
        throw new Error(message);
    }
    
    return await response.json();
}

// WebSocket Connection
async function initWebSocket() {
    try {
        ws = new WebSocket(await getWebSocketUrl());
        
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
        const files = await response.json();

        const songFiles = [];
        files.forEach(name => {
            if (name.endsWith('.json')) {
                songFiles.push(encodeURIComponent(name));
            }
        });
        
        // Load each song file
        const songPromises = songFiles.map(async (file) => {
            try {
                // Add cache-busting timestamp to force reload
                const cacheBuster = `?t=${Date.now()}`;
                const res = await fetch(`/songs/${file}${cacheBuster}`);
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
        songItem.tabIndex = 0;
        songItem.setAttribute('role', 'option');
        songItem.dataset.filename = song.filename;
        if (selectedSong && selectedSong.filename === song.filename) {
            songItem.classList.add('selected');
        }
        songItem.addEventListener('click', () => selectSong(song));
        songItem.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                selectSong(song);
            }
        });
        
        const songTitle = document.createElement('span');
        songTitle.className = 'song-title';
        songTitle.textContent = song.title;
        
        const editBtn = document.createElement('button');
        editBtn.className = 'song-edit-btn';
        editBtn.innerHTML = '✏️';
        editBtn.title = 'Edit song';
        editBtn.setAttribute('aria-label', `Edit ${song.title}`);
        editBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            openEditModal(song);
        });
        
        songItem.appendChild(songTitle);
        songItem.appendChild(editBtn);
        songList.appendChild(songItem);
    });
}

// Select a song
function selectSong(song) {
    selectedSong = song;
    
    // Update selected state in list
    document.querySelectorAll('.song-item').forEach(item => {
        item.classList.toggle('selected', item.dataset.filename === song.filename);
    });
    
    // Display phrases
    displayPhrases(song);
    
    // Close mobile menu if open
    if (typeof window.closeMobileMenuOnSelection === 'function') {
        window.closeMobileMenuOnSelection();
    }
}

// Display phrases for selected song
function displayPhrases(song) {
    // Show selected song info
    if (selectedSongInfo && selectedSongTitle) {
        selectedSongInfo.style.display = 'block';
        selectedSongTitle.textContent = song.title;
    }
    
    phrasesSection.innerHTML = '';
    activePhraseIndex = -1;
    
    song.phrases.forEach((phrase, index) => {
        const phraseItem = document.createElement('div');
        phraseItem.className = 'phrase-item';
        
        // Handle both string phrases (old format) and array phrases (new multi-line format)
        const displayText = phraseToText(phrase);
        
        phraseItem.textContent = displayText;
        phraseItem.tabIndex = 0;
        phraseItem.setAttribute('role', 'listitem');
        phraseItem.addEventListener('click', () => goLive(index));
        phraseItem.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                goLive(index);
            }
        });
        phrasesSection.appendChild(phraseItem);
    });
    updateTransport();
    
    // Switch to Songs tab automatically when song is selected
    switchTab('songs');
}

function phraseToText(phrase) {
    return Array.isArray(phrase) ? phrase.join('\n') : phrase;
}

function clearActivePhrase() {
    activePhraseIndex = -1;
    document.querySelectorAll('.phrase-item.active').forEach(p => p.classList.remove('active'));
    updateTransport();
}

function updateTransport() {
    const count = selectedSong ? selectedSong.phrases.length : 0;
    prevPhraseBtn.disabled = !count || activePhraseIndex <= 0;
    nextPhraseBtn.disabled = !count || activePhraseIndex >= count - 1;
    phrasePosition.textContent = count
        ? `${activePhraseIndex >= 0 ? activePhraseIndex + 1 : '–'} / ${count}`
        : '–';
}

function stepPhrase(delta) {
    const count = selectedSong ? selectedSong.phrases.length : 0;
    if (!count) return;
    const next = activePhraseIndex < 0 ? 0 : activePhraseIndex + delta;
    goLive(Math.max(0, Math.min(next, count - 1)));
}

// Send a verse of the selected song to the projector
function goLive(index) {
    if (!selectedSong || index < 0 || index >= selectedSong.phrases.length) return;
    const song = selectedSong;
    const items = phrasesSection.querySelectorAll('.phrase-item');
    items.forEach((p, i) => p.classList.toggle('active', i === index));
    activePhraseIndex = index;
    updateTransport();
    items[index].scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    
    let nextVersePreview = null;
    if (index < song.phrases.length - 1) {
        nextVersePreview = phraseToText(song.phrases[index + 1]).split('\n')[0] || null;
    }
    
    sendToProjector({
        type: 'song_phrase',
        text: phraseToText(song.phrases[index]),
        fontSize: currentFontSize,
        songTitle: song.title,
        nextVersePreview: nextVersePreview
    });
}

function showBlank() {
    sendToProjector({ type: 'blank', text: '', fontSize: currentFontSize });
    clearActivePhrase();
}

function isModalOpen() {
    return document.querySelector('.modal.show') !== null;
}

// Global keyboard shortcuts for live operation
function handleShortcut(e) {
    if (e.metaKey || e.ctrlKey || e.altKey || isModalOpen()) return;
    const target = e.target;
    const typing = target instanceof Element && target.matches('input, textarea, select, [contenteditable="true"]');
    
    if (typing) {
        if (e.key === 'Escape' && target === songSearch) {
            songSearch.blur();
            if (isSheetMode()) closeSongSheet();
        } else if (e.key === 'Enter' && target === songSearch) {
            const first = songList.querySelector('.song-item');
            if (first) first.click();
            songSearch.blur();
        }
        return;
    }
    
    const count = selectedSong ? selectedSong.phrases.length : 0;
    switch (e.key) {
        case 'ArrowDown':
        case 'ArrowRight':
        case 'PageDown':
        case ' ':
            if (!count) return;
            e.preventDefault();
            stepPhrase(1);
            break;
        case 'ArrowUp':
        case 'ArrowLeft':
        case 'PageUp':
            if (!count) return;
            e.preventDefault();
            stepPhrase(-1);
            break;
        case 'Home':
            if (!count) return;
            e.preventDefault();
            goLive(0);
            break;
        case 'End':
            if (!count) return;
            e.preventDefault();
            goLive(count - 1);
            break;
        case 'b':
        case 'B':
        case '.':
            e.preventDefault();
            showBlank();
            break;
        case 'w':
        case 'W':
            e.preventDefault();
            showWelcomeScreenBtn.click();
            break;
        case '/':
        case 's':
        case 'S':
            e.preventDefault();
            openSongSheet();
            break;
    }
}

const isSheetMode = () => window.matchMedia('(max-width: 959px)').matches;

function openSongSheet() {
    if (!isSheetMode()) {
        songSearch.focus();
        songSearch.select();
        return;
    }
    operatorSidebar.classList.add('mobile-open');
    mobileMenuOverlay.classList.add('active');
    openSongsBtn.setAttribute('aria-expanded', 'true');
    // Wait for the slide-in so iOS doesn't jump the page while opening the keyboard
    setTimeout(() => songSearch.focus({ preventScroll: true }), 260);
}

function closeSongSheet() {
    operatorSidebar.classList.remove('mobile-open');
    operatorSidebar.style.transform = '';
    mobileMenuOverlay.classList.remove('active');
    openSongsBtn.setAttribute('aria-expanded', 'false');
    if (document.activeElement === songSearch) songSearch.blur();
}

// Drag the sheet handle down to dismiss
function setupSongSheet() {
    openSongsBtn.addEventListener('click', openSongSheet);
    mobileMenuOverlay.addEventListener('click', closeSongSheet);
    window.closeMobileMenuOnSelection = () => {
        if (isSheetMode()) closeSongSheet();
    };

    let startY = 0;
    let deltaY = 0;
    let startTime = 0;
    let dragging = false;

    sheetHandle.addEventListener('pointerdown', (e) => {
        if (!isSheetMode()) return;
        dragging = true;
        startY = e.clientY;
        deltaY = 0;
        startTime = performance.now();
        operatorSidebar.classList.add('dragging');
        sheetHandle.setPointerCapture(e.pointerId);
    });

    sheetHandle.addEventListener('pointermove', (e) => {
        if (!dragging) return;
        deltaY = Math.max(0, e.clientY - startY);
        operatorSidebar.style.transform = `translateY(${deltaY}px)`;
    });

    const endDrag = () => {
        if (!dragging) return;
        dragging = false;
        operatorSidebar.classList.remove('dragging');
        const velocity = deltaY / Math.max(1, performance.now() - startTime);
        if (deltaY > operatorSidebar.offsetHeight * 0.25 || velocity > 0.5) {
            closeSongSheet();
        } else {
            operatorSidebar.style.transform = '';
        }
    };
    sheetHandle.addEventListener('pointerup', endDrag);
    sheetHandle.addEventListener('pointercancel', endDrag);
    sheetHandle.addEventListener('click', () => {
        if (deltaY < 4) closeSongSheet();
    });
}

// Setup event listeners
function setupEventListeners() {
    document.addEventListener('keydown', handleShortcut);
    
    if (blankQuickBtn) {
        blankQuickBtn.addEventListener('click', showBlank);
    }
    prevPhraseBtn.addEventListener('click', () => stepPhrase(-1));
    nextPhraseBtn.addEventListener('click', () => stepPhrase(1));
    
    // Tab switching
    document.querySelectorAll('.tab-button').forEach(button => {
        button.addEventListener('click', () => {
            const tabName = button.dataset.tab;
            switchTab(tabName);
        });
    });
    
    // Clear song selection
    if (clearSelectionBtn) {
        clearSelectionBtn.addEventListener('click', () => {
            clearSongSelection();
        });
    }
    
    // Song library: bottom sheet on mobile, persistent sidebar on desktop
    setupSongSheet();
    
    // Song search with Singlish support
    songSearch.addEventListener('input', (e) => {
        const searchTerm = e.target.value;
        
        // Toggle clear button visibility
        if (searchTerm.length > 0) {
            searchClearBtn.classList.add('visible');
        } else {
            searchClearBtn.classList.remove('visible');
        }
        
        // Use transliteration search if available, otherwise fall back to basic search
        let filteredSongs;
        if (typeof Transliteration !== 'undefined') {
            // Use fuzzy matching for better Singlish search experience
            filteredSongs = Transliteration.searchSongs(songs, searchTerm, true);
        } else {
            // Fallback to basic search
            const searchLower = searchTerm.toLowerCase();
            filteredSongs = songs.filter(song => 
                song.title.toLowerCase().includes(searchLower)
            );
        }
        
        displaySongs(filteredSongs);
    });
    
    // Clear search button
    searchClearBtn.addEventListener('click', () => {
        songSearch.value = '';
        searchClearBtn.classList.remove('visible');
        displaySongs(songs);
        songSearch.focus();
    });
    
    // Font size buttons (both compact and regular)
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
            clearActivePhrase();
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
            clearActivePhrase();
        }
    });
    
    // Welcome screen button
    showWelcomeScreenBtn.addEventListener('click', () => {
        sendToProjector({
            type: 'welcome_screen',
            text: 'Welcome Screen'
        });
        
        // Clear active phrase
        clearActivePhrase();
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
    
    // Bible tab - simple text button (same as Screens tab)
    if (showBibleVerseTabBtn && bibleVerseTabInput) {
        showBibleVerseTabBtn.addEventListener('click', () => {
            const text = bibleVerseTabInput.value.trim();
            if (text) {
                sendToProjector({
                    type: 'simple_slide',
                    text: text,
                    fontSize: currentFontSize
                });
                
                // Clear active phrase
                clearActivePhrase();
            }
        });
    }
    
    // Edit song modal handlers
    if (closeEditModal) {
        closeEditModal.addEventListener('click', closeEditModalFunc);
    }
    
    if (cancelEdit) {
        cancelEdit.addEventListener('click', closeEditModalFunc);
    }
    
    if (saveSongEdit) {
        saveSongEdit.addEventListener('click', saveEditedSong);
    }
    
    if (deleteSongBtn) {
        deleteSongBtn.addEventListener('click', deleteSong);
    }
    
    // Close edit modal when clicking outside
    if (editSongModal) {
        editSongModal.addEventListener('click', (e) => {
            if (e.target === editSongModal) {
                closeEditModalFunc();
            }
        });
    }
    
    // Export songs button
    if (exportSongsBtn) {
        exportSongsBtn.addEventListener('click', exportAllSongs);
    }
    
    // Import songs button
    if (importSongsBtn) {
        importSongsBtn.addEventListener('click', () => {
            // Create a file input element
            const fileInput = document.createElement('input');
            fileInput.type = 'file';
            fileInput.accept = '.json,application/json';
            
            fileInput.addEventListener('change', async (e) => {
                const file = e.target.files[0];
                if (file) {
                    await importSongsFromFile(file);
                }
            });
            
            // Trigger file selection
            fileInput.click();
        });
    }
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
        return await apiPost('/api/save-songs', { songs: songs });
        
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

// Switch between tabs
function switchTab(tabName) {
    // Remove active class from all tabs and content
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    // Add active class to selected tab and content
    const tabButton = document.querySelector(`[data-tab="${tabName}"]`);
    const tabContent = document.getElementById(`${tabName}Tab`);
    
    if (tabButton) tabButton.classList.add('active');
    if (tabContent) tabContent.classList.add('active');
}

// Clear song selection
function clearSongSelection() {
    selectedSong = null;
    
    // Clear selected state in song list
    document.querySelectorAll('.song-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    // Hide selected song info
    if (selectedSongInfo) {
        selectedSongInfo.style.display = 'none';
    }
    
    // Show no song selected message
    phrasesSection.innerHTML = `
        <div class="no-song-selected">
            <div class="empty-state-icon">🎵</div>
            <h3>No Song Selected</h3>
            <p>Tap <strong>Songs</strong> to find a song.</p>
        </div>
    `;
    activePhraseIndex = -1;
    updateTransport();
}

// Open edit modal
function openEditModal(song) {
    currentEditingSong = song;
    
    // Set title
    editSongTitle.value = song.title;
    
    // Convert phrases to text format
    let contentText = '';
    song.phrases.forEach((phrase, index) => {
        if (Array.isArray(phrase)) {
            contentText += phrase.join('\n');
        } else {
            contentText += phrase;
        }
        
        // Add blank line between verses (but not after the last one)
        if (index < song.phrases.length - 1) {
            contentText += '\n\n';
        }
    });
    
    editSongContent.value = contentText;
    
    // Show modal
    editSongModal.classList.add('show');
    editStatus.className = 'import-status';
    editStatus.textContent = '';
}

// Close edit modal
function closeEditModalFunc() {
    editSongModal.classList.remove('show');
    currentEditingSong = null;
    editSongTitle.value = '';
    editSongContent.value = '';
    editStatus.className = 'import-status';
    editStatus.textContent = '';
}

// Save edited song
async function saveEditedSong() {
    const newTitle = editSongTitle.value.trim();
    const content = editSongContent.value.trim();
    
    console.log('Saving song:', { newTitle, content });
    
    if (!newTitle) {
        showEditStatus('Please enter a song title.', 'error');
        return;
    }
    
    if (!content) {
        showEditStatus('Please enter song content.', 'error');
        return;
    }
    
    // Parse content into phrases
    const phrases = [];
    const verses = content.split(/\n\s*\n/); // Split by blank lines
    
    verses.forEach(verse => {
        const lines = verse.split('\n').map(line => line.trim()).filter(line => line);
        if (lines.length > 0) {
            phrases.push(lines);
        }
    });
    
    if (phrases.length === 0) {
        showEditStatus('No valid verses found.', 'error');
        return;
    }
    
    const updatedSong = {
        title: newTitle,
        phrases: phrases
    };
    
    console.log('Updated song object:', updatedSong);
    console.log('Current editing song:', currentEditingSong);
    
    try {
        showEditStatus('Saving changes...', 'info');
        
        const result = await apiPost('/api/update-song', {
            oldFilename: currentEditingSong.filename,
            song: updatedSong
        });
        console.log('Result:', result);
        
        if (result.success) {
            showEditStatus('Song updated successfully!', 'success');
            
            // Reload songs after a short delay
            setTimeout(() => {
                loadSongs();
                closeEditModalFunc();
                
                // If this was the selected song, clear selection
                if (selectedSong && selectedSong.filename === currentEditingSong.filename) {
                    clearSongSelection();
                }
            }, 1500);
        } else {
            showEditStatus(`Error: ${result.message}`, 'error');
        }
        
    } catch (error) {
        console.error('Save error:', error);
        showEditStatus(`Error: ${error.message}`, 'error');
    }
}

// Delete song
async function deleteSong() {
    if (!currentEditingSong) return;
    
    const confirmDelete = confirm(`Are you sure you want to delete "${currentEditingSong.title}"? This action cannot be undone.`);
    
    if (!confirmDelete) return;
    
    try {
        showEditStatus('Deleting song...', 'info');
        
        const result = await apiPost('/api/delete-song', {
            filename: currentEditingSong.filename
        });
        
        if (result.success) {
            showEditStatus('Song deleted successfully!', 'success');
            
            // Reload songs after a short delay
            setTimeout(() => {
                loadSongs();
                closeEditModalFunc();
                
                // If this was the selected song, clear selection
                if (selectedSong && selectedSong.filename === currentEditingSong.filename) {
                    clearSongSelection();
                }
            }, 1500);
        } else {
            showEditStatus(`Error: ${result.message}`, 'error');
        }
        
    } catch (error) {
        showEditStatus(`Error: ${error.message}`, 'error');
    }
}

// Show edit status message
function showEditStatus(message, type) {
    editStatus.textContent = message;
    editStatus.className = `import-status ${type}`;
}

// Export all songs to a JSON file
function exportAllSongs() {
    try {
        if (songs.length === 0) {
            alert('No songs to export!');
            return;
        }
        
        // Prepare songs data (without filename property)
        const exportData = songs.map(song => ({
            title: song.title,
            phrases: song.phrases
        }));
        
        // Create JSON string with pretty formatting
        const jsonString = JSON.stringify(exportData, null, 2);
        
        // Create a blob
        const blob = new Blob([jsonString], { type: 'application/json' });
        
        // Create download link
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        
        // Generate filename with current date
        const now = new Date();
        const dateStr = now.toISOString().split('T')[0]; // YYYY-MM-DD
        link.download = `church-songs-${dateStr}.json`;
        
        // Trigger download
        document.body.appendChild(link);
        link.click();
        
        // Cleanup
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
        
        console.log(`Exported ${songs.length} songs successfully`);
        
    } catch (error) {
        console.error('Error exporting songs:', error);
        alert(`Error exporting songs: ${error.message}`);
    }
}

// Import songs from a JSON file
async function importSongsFromFile(file) {
    try {
        // Read the file
        const fileContent = await file.text();
        
        // Parse JSON
        let importedSongs;
        try {
            importedSongs = JSON.parse(fileContent);
        } catch (parseError) {
            alert('Invalid JSON file. Please select a valid songs JSON file.');
            return;
        }
        
        // Validate the data
        if (!Array.isArray(importedSongs)) {
            alert('Invalid file format. Expected an array of songs.');
            return;
        }
        
        if (importedSongs.length === 0) {
            alert('No songs found in the file.');
            return;
        }
        
        // Validate each song has required fields
        const validSongs = importedSongs.filter(song => {
            return song.title && 
                   song.phrases && 
                   Array.isArray(song.phrases) && 
                   song.phrases.length > 0;
        });
        
        if (validSongs.length === 0) {
            alert('No valid songs found in the file. Each song must have a title and phrases.');
            return;
        }
        
        // Ask for confirmation
        const confirmImport = confirm(
            `Found ${validSongs.length} valid song(s) in the file.\n\n` +
            `Do you want to import them?\n\n` +
            `Note: Songs with duplicate titles will be skipped.`
        );
        
        if (!confirmImport) {
            return;
        }
        
        // Save songs using the existing API
        const result = await saveSongs(validSongs);
        
        if (result.success) {
            const message = 
                `Successfully imported ${result.saved} song(s)!\n` +
                (result.skipped > 0 ? `${result.skipped} song(s) skipped (already exist).` : '');
            
            alert(message);
            
            // Reload the song list
            await loadSongs();
        } else {
            alert(`Error importing songs: ${result.message}`);
        }
        
    } catch (error) {
        console.error('Error importing songs:', error);
        alert(`Error importing songs: ${error.message}`);
    }
}
