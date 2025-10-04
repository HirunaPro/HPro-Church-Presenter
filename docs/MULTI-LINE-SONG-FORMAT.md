# Multi-Line Song Format Guide

## Overview

The Church Presentation App now supports displaying multiple lines of song lyrics at once (verses). Each verse can contain 4-6 lines that will be displayed together on the projector screen.

## Song File Format

Song files are stored as JSON files in the `songs/` directory. The new format uses **arrays of lines** instead of individual strings.

### New Format (Multi-Line Verses)

```json
{
  "title": "Song Title",
  "phrases": [
    [
      "First line of verse 1",
      "Second line of verse 1",
      "Third line of verse 1",
      "Fourth line of verse 1"
    ],
    [
      "First line of verse 2",
      "Second line of verse 2",
      "Third line of verse 2",
      "Fourth line of verse 2"
    ]
  ]
}
```

### Old Format (Single Lines) - Still Supported

```json
{
  "title": "Song Title",
  "phrases": [
    "Single line 1",
    "Single line 2",
    "Single line 3"
  ]
}
```

**Note:** The app is backward compatible and supports both formats!

## Creating a New Song with Multi-Line Verses

### Example 1: 4-Line Verses

File: `songs/joyful-joyful.json`

```json
{
  "title": "Joyful, Joyful We Adore Thee",
  "phrases": [
    [
      "Joyful, joyful we adore Thee",
      "God of glory, Lord of love",
      "Hearts unfold like flowers before Thee",
      "Opening to the sun above"
    ],
    [
      "All Thy works with joy surround Thee",
      "Earth and heaven reflect Thy rays",
      "Stars and angels sing around Thee",
      "Center of unbroken praise"
    ],
    [
      "Thou art giving and forgiving",
      "Ever blessing, ever blest",
      "Wellspring of the joy of living",
      "Ocean depth of happy rest"
    ]
  ]
}
```

### Example 2: 5-Line Verses

File: `songs/it-is-well.json`

```json
{
  "title": "It Is Well With My Soul",
  "phrases": [
    [
      "When peace like a river attendeth my way",
      "When sorrows like sea billows roll",
      "Whatever my lot, Thou hast taught me to say",
      "It is well, it is well with my soul",
      ""
    ],
    [
      "It is well with my soul",
      "It is well, it is well with my soul",
      "",
      "",
      ""
    ],
    [
      "Though Satan should buffet, though trials should come",
      "Let this blest assurance control",
      "That Christ has regarded my helpless estate",
      "And hath shed His own blood for my soul",
      ""
    ]
  ]
}
```

### Example 3: 6-Line Verses

File: `songs/how-great-thou-art.json`

```json
{
  "title": "How Great Thou Art",
  "phrases": [
    [
      "O Lord my God, when I in awesome wonder",
      "Consider all the worlds Thy hands have made",
      "I see the stars, I hear the rolling thunder",
      "Thy power throughout the universe displayed",
      "",
      ""
    ],
    [
      "Then sings my soul, my Savior God, to Thee",
      "How great Thou art, how great Thou art",
      "Then sings my soul, my Savior God, to Thee",
      "How great Thou art, how great Thou art",
      "",
      ""
    ]
  ]
}
```

## Best Practices

### 1. **Verse Structure**
- Group lyrics into logical verses (typically 4 lines per verse)
- Each verse should be a complete thought or stanza
- Choruses can be separate verses

### 2. **Line Count**
- **Recommended:** 4 lines per verse (most common)
- **Acceptable:** 4-6 lines per verse
- **Avoid:** More than 6 lines (hard to read on screen)

### 3. **Empty Lines**
- Use empty strings `""` for spacing if needed
- Useful for shorter verses to maintain consistent formatting

### 4. **Chorus Handling**

You can include the chorus as a separate verse that you click multiple times:

```json
{
  "title": "Example Song",
  "phrases": [
    [
      "Verse 1 line 1",
      "Verse 1 line 2",
      "Verse 1 line 3",
      "Verse 1 line 4"
    ],
    [
      "Chorus line 1",
      "Chorus line 2",
      "Chorus line 3",
      "Chorus line 4"
    ],
    [
      "Verse 2 line 1",
      "Verse 2 line 2",
      "Verse 2 line 3",
      "Verse 2 line 4"
    ],
    [
      "Chorus line 1",
      "Chorus line 2",
      "Chorus line 3",
      "Chorus line 4"
    ]
  ]
}
```

### 5. **Line Length**
- Keep individual lines reasonably short (under 60 characters)
- Longer lines may wrap on smaller screens
- Test on your projector to ensure readability

## Converting Old Songs to New Format

### Before (Single Lines):
```json
{
  "title": "Amazing Grace",
  "phrases": [
    "Amazing grace how sweet the sound",
    "That saved a wretch like me",
    "I once was lost but now am found",
    "Was blind but now I see"
  ]
}
```

### After (Multi-Line Verses):
```json
{
  "title": "Amazing Grace",
  "phrases": [
    [
      "Amazing grace how sweet the sound",
      "That saved a wretch like me",
      "I once was lost but now am found",
      "Was blind but now I see"
    ]
  ]
}
```

Simply wrap groups of 4-6 lines in square brackets `[ ]` to create verses!

## How It Works

### In the Operator Panel
- Each verse appears as a single clickable block
- Lines within a verse are displayed with line breaks
- Click any verse to display it on the projector

### On the Projector
- All lines in the verse appear at once
- Lines are properly spaced for readability
- Font size applies to the entire verse
- Smooth transitions between verses

## Technical Details

### JSON Structure
```json
{
  "title": "String - The song title",
  "phrases": [
    // Array of verses
    [
      // Array of lines in verse 1
      "Line 1",
      "Line 2",
      "Line 3",
      "Line 4"
    ],
    [
      // Array of lines in verse 2
      "Line 1",
      "Line 2",
      "Line 3",
      "Line 4"
    ]
  ]
}
```

### Backwards Compatibility
The app automatically detects the format:
- **Array of strings** → Treated as single-line phrases (old format)
- **Array of arrays** → Treated as multi-line verses (new format)

You can even mix formats in the same song if needed!

## Troubleshooting

### Verse Not Displaying Properly
- Check JSON syntax (use a JSON validator)
- Ensure each verse is an array: `["line1", "line2"]`
- Make sure outer structure is also an array: `[ [...], [...] ]`

### Lines Not Breaking
- Verify you're using the new format (array of arrays)
- Check browser console (F12) for errors
- Refresh the operator page after modifying song files

### Text Too Small/Large
- Adjust font size using the operator controls
- Test different sizes for multi-line verses
- Medium or Large size works best for 4-line verses

## Examples in This Project

Check these files for reference:
- `songs/amazing-grace.json` - 4-line verses
- `songs/blessed-assurance.json` - 4-line verses with chorus
- `songs/how-great-thou-art.json` - 4-5 line verses

## Tips

1. **Preview Before Service** - Test all songs before the actual service
2. **Font Size** - "Medium" (48px) works well for 4-line verses
3. **Readability** - Use "Large" (64px) for shorter verses (2-3 lines)
4. **Consistency** - Keep verse length consistent within each song
5. **Backup** - Keep a backup of your original song files

---

**Updated:** October 2025
**Version:** 2.0 - Multi-line verse support
