# Export and Import Songs Feature

## Overview
This feature allows users to export all songs as a single JSON file and import songs from a JSON file, making it easy to backup, share, or restore song collections.

## Features Implemented

### 1. **Export All Songs**
- **Location**: Bottom of the song list in the operator sidebar
- **Button**: "⬇️ Export All" (blue button)
- **Functionality**:
  - Exports all currently loaded songs to a single JSON file
  - File is automatically named with the current date: `church-songs-YYYY-MM-DD.json`
  - Downloads directly to the user's default download folder
  - Exports clean data (removes internal `filename` property)
  - Pretty-formatted JSON for easy reading and editing

### 2. **Import Songs**
- **Location**: Bottom of the song list in the operator sidebar
- **Button**: "⬆️ Import" (orange button)
- **Functionality**:
  - Opens a file picker to select a JSON file
  - Validates the JSON structure
  - Checks each song has required fields (title and phrases)
  - Shows confirmation dialog with number of songs found
  - Uses existing `/api/save-songs` endpoint to save songs
  - Automatically skips songs with duplicate titles
  - Shows success/error messages with details
  - Automatically refreshes the song list after import

## File Structure

### Modified Files

#### 1. `operator.html`
Added export/import buttons container at the bottom of the song list:
```html
<div class="song-actions">
    <button class="song-action-btn export-btn" id="exportSongsBtn" title="Export all songs as JSON">
        ⬇️ Export All
    </button>
    <button class="song-action-btn import-btn" id="importSongsBtn" title="Import songs from JSON file">
        ⬆️ Import
    </button>
</div>
```

#### 2. `js/operator.js`
Added new functions:

**`exportAllSongs()`**
- Creates a JSON blob with all songs
- Generates download with timestamped filename
- Handles errors gracefully

**`importSongsFromFile(file)`**
- Reads and parses JSON file
- Validates song structure
- Shows confirmation dialog
- Calls existing `saveSongs()` API
- Reloads song list on success

#### 3. `css/style.css`
Added styles for:
- `.song-actions` - Container for buttons
- `.song-action-btn` - Base button style
- `.export-btn` - Blue export button with hover effects
- `.import-btn` - Orange import button with hover effects
- Mobile responsive styles for smaller screens

## JSON File Format

### Export Format
```json
[
  {
    "title": "Song Title",
    "phrases": [
      ["Line 1 of verse 1", "Line 2 of verse 1"],
      ["Line 1 of verse 2", "Line 2 of verse 2"]
    ]
  },
  {
    "title": "Another Song",
    "phrases": [
      ["Verse 1"],
      ["Verse 2"]
    ]
  }
]
```

### Import Requirements
- Must be valid JSON
- Must be an array of song objects
- Each song must have:
  - `title` (string)
  - `phrases` (array of arrays of strings)

## Usage Instructions

### To Export Songs:
1. Open the Operator Control page
2. Scroll to the bottom of the song list (or it's visible if you have few songs)
3. Click the "⬇️ Export All" button
4. The file will download automatically to your Downloads folder

### To Import Songs:
1. Open the Operator Control page
2. Click the "⬆️ Import" button at the bottom of the song list
3. Select a JSON file from your computer
4. Review the confirmation dialog showing how many songs were found
5. Click "OK" to proceed with import
6. Wait for the success message
7. The song list will automatically refresh

## Error Handling

### Export
- Shows alert if no songs to export
- Catches and displays any errors during export

### Import
- Validates JSON format
- Checks if data is an array
- Validates each song has required fields
- Filters out invalid songs
- Shows user-friendly error messages
- Skips duplicate songs automatically

## Benefits

1. **Backup**: Easy backup of entire song library
2. **Sharing**: Share song collections with other churches
3. **Migration**: Move songs between different installations
4. **Version Control**: Track changes to song library over time
5. **Bulk Editing**: Export, edit in text editor, re-import
6. **Disaster Recovery**: Restore songs if database is corrupted

## Technical Notes

- Uses JavaScript Blob API for file downloads
- Uses FileReader API for file uploads
- Leverages existing `/api/save-songs` endpoint
- No server-side changes required
- Fully client-side file handling
- Compatible with all modern browsers

## Future Enhancements (Optional)

- Export selected songs only
- Export/import with metadata (date created, author, etc.)
- Import from other formats (CSV, XML)
- Drag-and-drop file import
- Cloud backup integration
- Merge instead of skip duplicates
