# Verse Transition Effects

## Overview
The projector display now features smooth **fade in/out transition effects** when switching between verses, screens, and content. This creates a professional, polished presentation experience.

## Features

### 1. **Verse-to-Verse Transitions**
- When moving from one verse to another, the current verse fades out
- There's a brief moment of transition (0.5 seconds)
- The new verse then fades in smoothly
- The next verse preview also appears with a slight delay for a coordinated effect

### 2. **Blank Screen Transitions**
- Content fades out before the screen goes blank
- Creates a smooth transition instead of an abrupt change

### 3. **Welcome Screen Transitions**
- The welcome screen loads with a fade-in effect
- Previous content fades out before the welcome screen appears

### 4. **Consistent Timing**
All transitions use the same timing for consistency:
- **Fade Out Duration**: 0.5 seconds
- **Content Update**: Happens during the fade-out
- **Fade In Duration**: 0.5 seconds
- **Total Transition Time**: ~1 second

## Technical Details

### CSS Implementation
The transitions are implemented using CSS classes and transitions:

```css
.projector-content {
    transition: opacity 0.5s ease-in-out;
}

.projector-content.fade-out {
    opacity: 0;
}

.projector-content.fade-in {
    opacity: 1;
}
```

### JavaScript Sequence
The `updateDisplay()` function follows this sequence:
1. Add `fade-out` class to current content
2. Wait 500ms for fade-out to complete
3. Update the content (text, font size, etc.)
4. Add `fade-in` class to trigger fade-in
5. Update the next verse preview with a slight delay

## Benefits

✅ **Professional Appearance**: Smooth transitions look more polished than instant changes

✅ **Reduced Eye Strain**: Gradual changes are easier on the audience's eyes

✅ **Better Readability**: The brief pause between verses helps the audience process the change

✅ **Enhanced Next Verse Preview**: The preview appears after the main content, creating a coordinated flow

## Customization

### Adjusting Transition Speed
To change the transition speed, modify two values:

1. **CSS** (`css/style.css`):
```css
.projector-content {
    transition: opacity 0.5s ease-in-out; /* Change 0.5s */
}
```

2. **JavaScript** (`js/projector.js`):
```javascript
setTimeout(() => {
    // ... content update
}, 500); // Change 500 (in milliseconds, 1000 = 1 second)
```

**Note**: Keep these values synchronized (0.5s = 500ms)

### Suggested Speeds
- **Fast**: 0.3s (300ms) - Snappy, energetic
- **Medium**: 0.5s (500ms) - **Current default** - Balanced
- **Slow**: 0.8s (800ms) - Elegant, deliberate

## Browser Compatibility
This feature uses standard CSS transitions and is compatible with all modern browsers:
- ✅ Chrome/Edge
- ✅ Firefox
- ✅ Safari
- ✅ Opera

## Future Enhancements
Potential future improvements:
- [ ] Multiple transition styles (slide, cross-fade, zoom)
- [ ] User-configurable transition speed from operator panel
- [ ] Different transitions for different content types
- [ ] Directional transitions (left/right for previous/next)
