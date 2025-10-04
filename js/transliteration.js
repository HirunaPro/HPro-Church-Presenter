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
        'ත': 'tha', 'ථ': 'thha', 'ද': 'dha', 'ධ': 'dhha', 'න': 'na', 'ඳ': 'nda',
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
            let nextNextChar = i + 2 < text.length ? text[i + 2] : '';
            
            // Check if this is a Sinhala consonant
            const isSinhalaConsonant = char >= 'ක' && char <= 'හ';
            
            if (isSinhalaConsonant) {
                // Get base consonant transliteration
                let consonant = this.sinhalaMap[char] || char;
                
                // Check for virama (්) which removes the inherent 'a'
                if (nextChar === '්') {
                    // Remove the 'a' from consonant if it ends with 'a'
                    if (consonant.endsWith('a')) {
                        consonant = consonant.slice(0, -1);
                    }
                    
                    // Check if there's a vowel sign after virama
                    if (this.sinhalaMap[nextNextChar] && nextNextChar >= 'ා' && nextNextChar <= 'ෞ') {
                        // Consonant + virama + vowel sign
                        result += consonant + this.sinhalaMap[nextNextChar];
                        i += 3;
                        continue;
                    } else if (nextNextChar === '‍') {
                        // Zero-width joiner (U+200D) - check for vowel after it
                        let charAfterZWJ = i + 3 < text.length ? text[i + 3] : '';
                        if (this.sinhalaMap[charAfterZWJ]) {
                            result += consonant + this.sinhalaMap[charAfterZWJ];
                            i += 4;
                            continue;
                        }
                    }
                    
                    // Just consonant + virama (no vowel following)
                    result += consonant;
                    i += 2;
                    continue;
                }
                // Check for vowel sign directly after consonant (no virama)
                else if (this.sinhalaMap[nextChar] && nextChar >= 'ා' && nextChar <= 'ෞ') {
                    // Remove inherent 'a' and add vowel
                    if (consonant.endsWith('a')) {
                        consonant = consonant.slice(0, -1);
                    }
                    result += consonant + this.sinhalaMap[nextChar];
                    i += 2;
                    continue;
                }
                // Just the consonant with inherent 'a'
                else {
                    result += consonant;
                    i++;
                    continue;
                }
            }
            
            // Try two-character combinations for Tamil
            let twoChars = char + nextChar;
            if (this.tamilMap[twoChars]) {
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
        
        // Normalize and convert target to singlish
        let targetSinglish = this.normalize(this.toSinglish(targetText));
        let normalizedSearch = this.normalize(searchTerm);
        
        // Apply phonetic normalization to both search and target
        // This makes variations match each other
        const normalizePhonetic = (text) => {
            return text
                // Aspirated consonants can match unaspirated
                .replace(/dh/g, 'd')
                .replace(/th/g, 't')
                .replace(/bh/g, 'b')
                .replace(/gh/g, 'g')
                .replace(/kh/g, 'k')
                .replace(/ph/g, 'p')
                .replace(/chh/g, 'ch')
                // Vowel variations - order matters!
                .replace(/aae/g, 'e')  // aae -> e
                .replace(/mae/g, 'me')  // mae -> me (common in Sinhala)
                .replace(/ae/g, 'e')  // ae and e are similar
                .replace(/ai/g, 'i')  // ai can sound like i
                // Double vowels can match single
                .replace(/aa+/g, 'a')
                .replace(/ee+/g, 'e')
                .replace(/ii+/g, 'i')
                .replace(/oo+/g, 'o')
                .replace(/uu+/g, 'u')
                // Common consonant equivalents
                .replace(/w/g, 'v')
                .replace(/y/g, 'j')  // y and j are often interchangeable (Jesus/Yesus)
                .replace(/nda/g, 'nd')
                .replace(/ll/g, 'l')
                .replace(/sh/g, 's')
                // Allow for optional trailing 'a' (common in Sinhala)
                .replace(/na$/g, 'n')
                // Remove duplicate letters
                .replace(/(.)\1+/g, '$1');
        };
        
        const phoneticSearch = normalizePhonetic(normalizedSearch);
        const phoneticTarget = normalizePhonetic(targetSinglish);
        
        // Check if phonetically normalized search appears in target
        if (phoneticTarget.includes(phoneticSearch)) {
            return true;
        }
        
        // Also try with regex for more flexibility
        try {
            // Create a pattern that allows optional 'h' after certain consonants
            let pattern = normalizedSearch
                .replace(/d/g, 'd[h]?')
                .replace(/t/g, 't[h]?')
                .replace(/b/g, 'b[h]?')
                .replace(/g/g, 'g[h]?')
                .replace(/k/g, 'k[h]?')
                .replace(/p/g, 'p[h]?')
                .replace(/c/g, 'c[h]?')
                .replace(/s/g, 's[h]?')
                // Allow single or double vowels
                .replace(/a/g, 'a+')
                .replace(/e/g, 'e+')
                .replace(/i/g, 'i+')
                .replace(/o/g, 'o+')
                .replace(/u/g, 'u+')
                // v and w are interchangeable
                .replace(/v/g, '[vw]')
                .replace(/w/g, '[vw]')
                // l and ll
                .replace(/l/g, 'l+');
            
            const regex = new RegExp(pattern, 'i');
            return regex.test(targetSinglish);
        } catch (e) {
            // If regex fails, use the phonetic match result
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
