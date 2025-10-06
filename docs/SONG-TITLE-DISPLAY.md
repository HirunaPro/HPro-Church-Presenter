# Song Title Display Feature

## Overview
The projector now displays the **song title** in the top-left corner of the screen when showing song verses. This helps the audience and technical team know which song is currently being displayed.

## Visual Appearance

### Location & Style
- **Position**: Top-left corner (20px from top and left)
- **Font Size**: 20px (small, unobtrusive)
- **Background**: Semi-transparent dark background with blur effect
- **Color**: White text with slight transparency
- **Max Width**: 400px (with text ellipsis for long titles)

### Example
```
┌─────────────────────────────────────────┐
│ [Song Title Here]                       │
│                                         │
│                                         │
│         Main Verse Content              │
│           (Center)                      │
│                                         │
│                                         │
│              Next: [Preview]            │
└─────────────────────────────────────────┘
```

## When It Appears

✅ **Shows When:**
- Displaying song verses/phrases
- Content type is `song_phrase`
- Song title is included in the data

❌ **Hidden When:**
- Welcome screen is displayed
- Blank screen is active
- Bible verses or custom text (without song context)
- No song title in content data

## Technical Implementation

### HTML Structure
```html
<div class="song-title-display" id="songTitleDisplay">
    <!-- Song title will appear here -->
</div>
```

### CSS Styling
```css
.song-title-display {
    position: fixed;
    top: 20px;
    left: 20px;
    background: rgba(0, 0, 0, 0.4);
    color: rgba(255, 255, 255, 0.8);
    padding: 8px 16px;
    border-radius: 6px;
    font-size: 20px;
    opacity: 0;
    transition: opacity 0.3s ease-in-out;
}

.song-title-display.visible {
    opacity: 1;
}
```

### JavaScript Logic
The title appears with a coordinated fade-in effect:
1. Content fades out
2. New verse and title data loaded
3. Title fades in (300ms delay for coordination)

## Benefits

✅ **Audience Reference**: People can see which song is being sung

✅ **Technical Clarity**: Operators and worship leaders know the current song

✅ **Non-Intrusive**: Small size and subtle design don't distract from lyrics

✅ **Professional Look**: Matches the overall polished appearance

✅ **Context Awareness**: Especially helpful in multi-song worship sets

## Customization Options

### Adjust Font Size
In `css/style.css`:
```css
.song-title-display {
    font-size: 20px; /* Change this value */
}
```

Suggested sizes:
- **Extra Small**: 16px - Very subtle
- **Small**: 18px - Discreet
- **Medium**: 20px - **Current default** - Balanced
- **Large**: 24px - More visible

### Adjust Position
In `css/style.css`:
```css
.song-title-display {
    top: 20px;    /* Distance from top */
    left: 20px;   /* Distance from left */
}
```

Alternative positions:
- **Top-Right**: `right: 20px;` (remove `left`)
- **Bottom-Left**: `bottom: 20px;` (remove `top`)
- **Center-Top**: Add `left: 50%; transform: translateX(-50%);`

### Adjust Transparency
In `css/style.css`:
```css
.song-title-display {
    background: rgba(0, 0, 0, 0.4);        /* Dark background opacity */
    color: rgba(255, 255, 255, 0.8);       /* Text opacity */
}
```

Values range from 0.0 (fully transparent) to 1.0 (fully opaque)

### Change Background Style
More subtle:
```css
background: rgba(0, 0, 0, 0.2);  /* Lighter background */
```

More prominent:
```css
background: rgba(0, 0, 0, 0.7);  /* Darker background */
color: rgba(255, 255, 255, 1);   /* Fully opaque text */
```

## Integration with Other Features

### Works With:
- ✅ **Fade Transitions**: Title fades in/out smoothly with verses
- ✅ **Next Verse Preview**: Both appear together harmoniously
- ✅ **Font Size Changes**: Adapts to different content sizes
- ✅ **Blank Screen**: Properly hidden when screen goes blank
- ✅ **Welcome Screen**: Hidden to keep welcome clean

### Data Flow:
The operator sends the song title automatically when clicking a verse:
```javascript
sendToProjector({
    type: 'song_phrase',
    text: phraseText,
    fontSize: currentFontSize,
    songTitle: song.title,        // ← Song title included
    nextVersePreview: nextVersePreview
});
```

## Browser Compatibility
- ✅ Chrome/Edge
- ✅ Firefox
- ✅ Safari
- ✅ Opera

Uses standard CSS features (backdrop-filter may vary by browser but has graceful fallback)

## Future Enhancements
Potential improvements:
- [ ] Toggle visibility from operator panel
- [ ] Different styles per song type (worship, hymn, etc.)
- [ ] Configurable position from settings
- [ ] Show verse/chorus labels
- [ ] Custom color schemes
