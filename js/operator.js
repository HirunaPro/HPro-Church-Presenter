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
const mobileMenuToggle = document.getElementById('mobileMenuToggle');
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
        
        const songTitle = document.createElement('span');
        songTitle.className = 'song-title';
        songTitle.textContent = song.title;
        songTitle.addEventListener('click', () => selectSong(song));
        
        const editBtn = document.createElement('button');
        editBtn.className = 'song-edit-btn';
        editBtn.innerHTML = '✏️';
        editBtn.title = 'Edit song';
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
        item.classList.remove('selected');
        const titleSpan = item.querySelector('.song-title');
        if (titleSpan && titleSpan.textContent === song.title) {
            item.classList.add('selected');
        }
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
        
        phraseItem.textContent = displayText;
        
        phraseItem.addEventListener('click', () => {
            // Remove active class from all phrases
            document.querySelectorAll('.phrase-item').forEach(p => {
                p.classList.remove('active');
            });
            
            // Add active class to clicked phrase
            phraseItem.classList.add('active');
            
            // Get the next verse's first line for preview
            let nextVersePreview = null;
            if (index < song.phrases.length - 1) {
                const nextPhrase = song.phrases[index + 1];
                if (Array.isArray(nextPhrase) && nextPhrase.length > 0) {
                    nextVersePreview = nextPhrase[0];
                } else if (typeof nextPhrase === 'string') {
                    // For old format, take the first line if it contains newlines
                    nextVersePreview = nextPhrase.split('\n')[0];
                }
            }
            
            // Send to projector
            sendToProjector({
                type: 'song_phrase',
                text: phraseText,
                fontSize: currentFontSize,
                songTitle: song.title,
                nextVersePreview: nextVersePreview
            });
        });
        phrasesSection.appendChild(phraseItem);
    });
    
    // Switch to Songs tab automatically when song is selected
    switchTab('songs');
}

// Setup event listeners
function setupEventListeners() {
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
    
    // Mobile menu toggle
    if (mobileMenuToggle && operatorSidebar && mobileMenuOverlay) {
        mobileMenuToggle.addEventListener('click', () => {
            operatorSidebar.classList.toggle('mobile-open');
            mobileMenuOverlay.classList.toggle('active');
            
            // Update button icon
            if (operatorSidebar.classList.contains('mobile-open')) {
                mobileMenuToggle.innerHTML = '✕';
                mobileMenuToggle.setAttribute('aria-label', 'Close menu');
            } else {
                mobileMenuToggle.innerHTML = '☰';
                mobileMenuToggle.setAttribute('aria-label', 'Toggle menu');
            }
        });
        
        // Close mobile menu when clicking on overlay
        mobileMenuOverlay.addEventListener('click', () => {
            operatorSidebar.classList.remove('mobile-open');
            mobileMenuOverlay.classList.remove('active');
            mobileMenuToggle.innerHTML = '☰';
            mobileMenuToggle.setAttribute('aria-label', 'Toggle menu');
        });
        
        // Close mobile menu when song is selected
        const closeMobileMenuOnSelection = () => {
            if (window.innerWidth <= 768 && operatorSidebar.classList.contains('mobile-open')) {
                operatorSidebar.classList.remove('mobile-open');
                mobileMenuOverlay.classList.remove('active');
                mobileMenuToggle.innerHTML = '☰';
                mobileMenuToggle.setAttribute('aria-label', 'Toggle menu');
            }
        };
        
        // Store the function for use in selectSong
        window.closeMobileMenuOnSelection = closeMobileMenuOnSelection;
    }
    
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
                document.querySelectorAll('.phrase-item').forEach(p => {
                    p.classList.remove('active');
                });
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
            <p>Open the menu and select a song to view its phrases</p>
        </div>
    `;
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
        
        const response = await fetch('/api/update-song', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                oldFilename: currentEditingSong.filename,
                song: updatedSong
            })
        });
        
        console.log('Response status:', response.status);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Server error response:', errorText);
            throw new Error(`Server error: ${response.status}`);
        }
        
        const result = await response.json();
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
        
        const response = await fetch('/api/delete-song', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                filename: currentEditingSong.filename
            })
        });
        
        if (!response.ok) {
            throw new Error(`Server error: ${response.status}`);
        }
        
        const result = await response.json();
        
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
