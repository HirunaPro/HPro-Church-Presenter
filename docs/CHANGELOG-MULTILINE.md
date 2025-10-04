# Multi-Line Verse Update - Change Summary

## What Changed

The Church Presentation App has been updated to support **multi-line verse display**. Instead of showing one line at a time, you can now display 4-6 lines together as a complete verse.

## Files Modified

### 1. **js/projector.js**
- Updated to preserve line breaks in displayed text
- Changed from `textContent` to `innerHTML` to support `<br>` tags
- Converts `\n` characters to HTML line breaks

### 2. **js/operator.js**
- Added support for both old (single-line) and new (multi-line) formats
- Automatically detects if a phrase is an array or string
- Joins array lines with newline characters for display
- Added `white-space: pre-wrap` styling to phrase items

### 3. **css/style.css**
- Improved line-height for multi-line display
- Added specific line-height for each font size:
  - Small (36px): 1.6 line-height
  - Medium (48px): 1.7 line-height
  - Large (64px): 1.8 line-height
  - Extra Large (80px): 1.8 line-height

### 4. **Song Files**
- **amazing-grace.json** - Converted to 4 verses with 4 lines each
- **blessed-assurance.json** - Converted to 4 verses with 4 lines each
- **how-great-thou-art.json** - Converted to 5 verses with 4-5 lines each
- **example-multi-line.json** - NEW: Example file demonstrating the format

### 5. **Documentation**
- **README.md** - Updated to mention multi-line support
- **MULTI-LINE-SONG-FORMAT.md** - NEW: Comprehensive guide for the new format

## New Song Format

### Before (Old Format - Still Supported)
```json
{
  "title": "Song Title",
  "phrases": [
    "Line 1",
    "Line 2",
    "Line 3"
  ]
}
```

### After (New Format - Recommended)
```json
{
  "title": "Song Title",
  "phrases": [
    [
      "Line 1 of verse 1",
      "Line 2 of verse 1",
      "Line 3 of verse 1",
      "Line 4 of verse 1"
    ],
    [
      "Line 1 of verse 2",
      "Line 2 of verse 2",
      "Line 3 of verse 2",
      "Line 4 of verse 2"
    ]
  ]
}
```

## How to Use

### For Users
1. **Start the server** as usual: `python server.py`
2. **Open operator panel** and select a song
3. **Click any verse** - all 4-6 lines will display on the projector at once
4. **Adjust font size** as needed (Medium or Large works best for multi-line)

### For Song Creators
1. **Create/edit JSON files** in the `songs/` folder
2. **Group lyrics** into verses of 4-6 lines (arrays)
3. **Each verse** is an array of strings
4. **Refresh** the operator page to load new songs

## Benefits

✅ **More Context** - Show entire verses instead of single lines
✅ **Better Readability** - Congregation can read ahead and follow along
✅ **Natural Flow** - Matches how songs are typically structured
✅ **Backward Compatible** - Old single-line songs still work
✅ **Flexible** - Support both formats in the same app

## Testing

To test the changes:
1. Start the server
2. Open operator panel
3. Select "Amazing Grace" or "Example Multi-Line Song"
4. Click any verse
5. The projector should display all lines at once with proper spacing

## Font Size Recommendations

- **4 lines**: Medium (48px) or Large (64px)
- **5 lines**: Medium (48px)
- **6 lines**: Small (36px) or Medium (48px)

Test on your actual projector to find the best size!

## Troubleshooting

**Lines not showing line breaks?**
- Make sure you're using the new array format
- Refresh the operator page after editing song files

**Text too small/large?**
- Use the font size controls (Small, Medium, Large, Extra Large)
- Medium works best for most multi-line verses

**Old songs not working?**
- Don't worry! The app still supports the old single-line format
- Both formats work simultaneously

## Next Steps

1. **Review** the example files in the `songs/` folder
2. **Read** the detailed guide in `MULTI-LINE-SONG-FORMAT.md`
3. **Convert** your existing songs to the new format (or keep them as-is)
4. **Test** before your next service

---

**Update Date:** October 4, 2025
**Version:** 2.0 - Multi-line verse support
