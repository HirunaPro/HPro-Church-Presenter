// Transliteration utility for Sinhala and Tamil to Singlish (Romanized)
// Supports phonetic search in English for Sinhala and Tamil songs

const Transliteration = {
    // Sinhala to Singlish mapping
    sinhalaMap: {
        // Vowels
        'අ': 'a', 'ආ': 'aa', 'ඇ': 'ae', 'ඈ': 'aae', 'ඉ': 'i', 'ඊ': 'ii', 
        'උ': 'u', 'ඌ': 'uu', 'ඍ': 'ru', 'ඎ': 'ruu', 'ඏ': 'lu', 'ඐ': 'luu',
        'එ': 'e', 'ඒ': 'ee', 'ඓ': 'ai', 'ඔ': 'o', 'ඕ': 'oo', 'ඖ': 'au',
        
        // Consonants
        'ක': 'ka', 'ඛ': 'kha', 'ග': 'ga', 'ඝ': 'gha', 'ඞ': 'nga',
        'ච': 'cha', 'ඡ': 'chha', 'ජ': 'ja', 'ඣ': 'jha', 'ඤ': 'gna',
        'ට': 'ta', 'ඨ': 'tta', 'ඩ': 'da', 'ඪ': 'dda', 'ණ': 'na',
        'ත': 'tha', 'ථ': 'thha', 'ද': 'dha', 'ධ': 'dhha', 'න': 'na',
        'ප': 'pa', 'ඵ': 'pha', 'බ': 'ba', 'භ': 'bha', 'ම': 'ma',
        'ය': 'ya', 'ර': 'ra', 'ල': 'la', 'ව': 'va', 'ශ': 'sha',
        'ෂ': 'sha', 'ස': 'sa', 'හ': 'ha', 'ළ': 'lla', 'ෆ': 'fa',
        
        // Vowel signs (combining marks)
        'ා': 'aa', 'ැ': 'ae', 'ෑ': 'aae', 'ි': 'i', 'ී': 'ii',
        'ු': 'u', 'ූ': 'uu', 'ෘ': 'ru', 'ෲ': 'ruu', 'ෟ': 'lu', 'ෳ': 'luu',
        'ෙ': 'e', 'ේ': 'ee', 'ෛ': 'ai', 'ො': 'o', 'ෝ': 'oo', 'ෞ': 'au',
        
        // Special signs
        'ං': 'ng', 'ඃ': 'h', '්': '', 'ෘ': 'ru', 'ෲ': 'ruu'
    },
    
    // Tamil to Singlish mapping
    tamilMap: {
        // Vowels
        'அ': 'a', 'ஆ': 'aa', 'இ': 'i', 'ஈ': 'ii', 'உ': 'u', 'ஊ': 'uu',
        'எ': 'e', 'ஏ': 'ee', 'ஐ': 'ai', 'ஒ': 'o', 'ஓ': 'oo', 'ஔ': 'au',
        
        // Consonants
        'க': 'ka', 'ங': 'nga', 'ச': 'cha', 'ஞ': 'gna', 'ட': 'ta',
        'ண': 'na', 'த': 'tha', 'ன': 'na', 'ப': 'pa', 'ம': 'ma',
        'ய': 'ya', 'ர': 'ra', 'ல': 'la', 'வ': 'va', 'ழ': 'zha',
        'ள': 'lla', 'ற': 'ra', 'ன': 'na', 'ஜ': 'ja', 'ஷ': 'sha',
        'ஸ': 'sa', 'ஹ': 'ha', 'க்ஷ': 'ksha', 'ஶ': 'sha', 'ஶ்ரீ': 'shri',
        
        // Vowel signs (combining marks)
        'ா': 'aa', 'ி': 'i', 'ீ': 'ii', 'ு': 'u', 'ூ': 'uu',
        'ெ': 'e', 'ே': 'ee', 'ை': 'ai', 'ொ': 'o', 'ோ': 'oo', 'ௌ': 'au',
        
        // Special signs
        'ஂ': 'h', 'ஃ': 'h', '்': ''
    },
    
    /**
     * Transliterate a text from Sinhala/Tamil to Singlish
     * @param {string} text - The text to transliterate
     * @returns {string} - The transliterated text
     */
    toSinglish: function(text) {
        if (!text) return '';
        
        let result = '';
        let i = 0;
        
        while (i < text.length) {
            let char = text[i];
            let nextChar = i + 1 < text.length ? text[i + 1] : '';
            let twoChars = char + nextChar;
            
            // Try two-character combinations first (for special combinations)
            if (this.sinhalaMap[twoChars]) {
                result += this.sinhalaMap[twoChars];
                i += 2;
            } else if (this.tamilMap[twoChars]) {
                result += this.tamilMap[twoChars];
                i += 2;
            }
            // Try single character
            else if (this.sinhalaMap[char]) {
                result += this.sinhalaMap[char];
                i++;
            } else if (this.tamilMap[char]) {
                result += this.tamilMap[char];
                i++;
            }
            // Keep the character as-is (spaces, punctuation, numbers, etc.)
            else {
                result += char;
                i++;
            }
        }
        
        return result.toLowerCase();
    },
    
    /**
     * Normalize a string for better matching
     * Removes extra spaces, converts to lowercase, removes special chars
     * @param {string} text - The text to normalize
     * @returns {string} - The normalized text
     */
    normalize: function(text) {
        return text
            .toLowerCase()
            .replace(/[^\w\s]/g, '') // Remove special characters
            .replace(/\s+/g, ' ')     // Normalize spaces
            .trim();
    },
    
    /**
     * Check if a search term matches a target text
     * Supports both native script and Singlish search
     * @param {string} searchTerm - The search term (can be Singlish, Sinhala, or Tamil)
     * @param {string} targetText - The target text to search in
     * @returns {boolean} - True if there's a match
     */
    matches: function(searchTerm, targetText) {
        if (!searchTerm || !targetText) return false;
        
        searchTerm = searchTerm.trim();
        if (searchTerm === '') return true;
        
        // Normalize the search term
        const normalizedSearch = this.normalize(searchTerm);
        
        // Method 1: Direct match (original text)
        if (this.normalize(targetText).includes(normalizedSearch)) {
            return true;
        }
        
        // Method 2: Transliterate target to Singlish and match
        const targetSinglish = this.normalize(this.toSinglish(targetText));
        if (targetSinglish.includes(normalizedSearch)) {
            return true;
        }
        
        // Method 3: Transliterate search term to check if user typed in Sinhala/Tamil
        const searchSinglish = this.normalize(this.toSinglish(searchTerm));
        if (targetSinglish.includes(searchSinglish)) {
            return true;
        }
        
        return false;
    },
    
    /**
     * Advanced fuzzy matching with phonetic similarity
     * Handles common variations in romanization
     * @param {string} searchTerm - The search term
     * @param {string} targetText - The target text
     * @returns {boolean} - True if there's a fuzzy match
     */
    fuzzyMatches: function(searchTerm, targetText) {
        if (this.matches(searchTerm, targetText)) {
            return true;
        }
        
        // Phonetic variations in Singlish typing
        const variations = {
            'aa': ['a', 'aa', 'ā'],
            'ee': ['e', 'ee', 'ē', 'i'],
            'oo': ['o', 'oo', 'ō', 'u'],
            'ii': ['i', 'ii', 'ī'],
            'uu': ['u', 'uu', 'ū'],
            'ae': ['a', 'ae', 'ä'],
            'w': ['v', 'w'],
            'v': ['v', 'w'],
            'sh': ['sh', 's'],
            'ch': ['ch', 'c'],
            'th': ['th', 't'],
            'dh': ['dh', 'd']
        };
        
        // Create regex pattern with variations
        let pattern = this.normalize(searchTerm);
        for (let [key, values] of Object.entries(variations)) {
            const regex = new RegExp(key, 'g');
            pattern = pattern.replace(regex, `(?:${values.join('|')})`);
        }
        
        try {
            const regex = new RegExp(pattern, 'i');
            const targetSinglish = this.normalize(this.toSinglish(targetText));
            return regex.test(targetSinglish);
        } catch (e) {
            // If regex fails, fall back to basic match
            return false;
        }
    },
    
    /**
     * Search songs by title with Singlish support
     * @param {Array} songs - Array of song objects
     * @param {string} searchTerm - The search term
     * @param {boolean} useFuzzy - Whether to use fuzzy matching
     * @returns {Array} - Filtered array of songs
     */
    searchSongs: function(songs, searchTerm, useFuzzy = false) {
        if (!searchTerm || searchTerm.trim() === '') {
            return songs;
        }
        
        const matchFunction = useFuzzy ? this.fuzzyMatches.bind(this) : this.matches.bind(this);
        
        return songs.filter(song => {
            // Search in title
            if (matchFunction(searchTerm, song.title)) {
                return true;
            }
            
            // Optionally search in phrases (can be slow for large song lists)
            if (song.phrases && Array.isArray(song.phrases)) {
                for (let phrase of song.phrases) {
                    const phraseText = Array.isArray(phrase) ? phrase.join(' ') : phrase;
                    if (matchFunction(searchTerm, phraseText)) {
                        return true;
                    }
                }
            }
            
            return false;
        });
    }
};

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Transliteration;
}
