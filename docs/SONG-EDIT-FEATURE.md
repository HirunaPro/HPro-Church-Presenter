# Song Edit Feature Documentation

## Overview
The Church Presentation App now includes a comprehensive song editing feature that allows operators to edit and delete songs directly from the operator interface.

## Features Added

### 1. Edit Song Button
- Each song in the song list now has an **edit button (✏️)** next to it
- Clicking the edit button opens the Edit Song modal
- The button appears on hover and is always visible on selected songs

### 2. Edit Song Modal
The edit modal includes:
- **Song Title Field**: Edit the song's title
- **Song Content Field**: Edit the song's lyrics/phrases
- **Save Changes Button**: Save the modifications
- **Delete Song Button**: Remove the song permanently
- **Cancel Button**: Close without saving

### 3. Content Format
When editing songs, follow this format:
- Separate each verse with a **blank line**
- Each line within a verse will be displayed separately on the projector
- The first line is not automatically the title (title is in a separate field)

**Example:**
```
Verse 1 line 1
Verse 1 line 2
Verse 1 line 3

Verse 2 line 1
Verse 2 line 2

Chorus line 1
Chorus line 2
```

### 4. Smart Filename Handling
- When you change a song's title, the system automatically:
  - Generates a new filename based on the new title
  - Deletes the old file
  - Creates a new file with the updated content
- Filename generation removes special characters and uses hyphens

### 5. Delete Functionality
- Click the **Delete Song** button in the edit modal
- A confirmation dialog appears to prevent accidental deletion
- Once confirmed, the song is permanently removed
- The song list automatically refreshes

## Usage Instructions

### To Edit a Song:
1. Find the song in the song list
2. Click the **✏️ edit button** next to the song name
3. Modify the title and/or content as needed
4. Click **Save Changes**
5. Wait for the success message
6. The song list will automatically refresh

### To Delete a Song:
1. Open the song in the edit modal (click the ✏️ button)
2. Click the **Delete Song** button
3. Confirm the deletion when prompted
4. The song will be removed and the list will refresh

### To Cancel Editing:
- Click the **Cancel** button
- Click the **X** in the top-right corner
- Click outside the modal window

## Technical Implementation

### Frontend (operator.js)
New functions added:
- `openEditModal(song)` - Opens the edit modal with song data
- `closeEditModalFunc()` - Closes the edit modal
- `saveEditedSong()` - Sends update request to server
- `deleteSong()` - Sends delete request to server
- `showEditStatus(message, type)` - Displays status messages

### Backend (server.py, server-optimized.py, server-azure.py)
New API endpoints:
- `POST /api/update-song` - Updates an existing song
- `POST /api/delete-song` - Deletes a song

Request format for update:
```json
{
  "oldFilename": "original-song-name.json",
  "song": {
    "title": "New Song Title",
    "phrases": [
      ["Line 1", "Line 2"],
      ["Line 3", "Line 4"]
    ]
  }
}
```

Request format for delete:
```json
{
  "filename": "song-to-delete.json"
}
```

### Styling (style.css)
New CSS classes:
- `.song-title` - Styles the song name in the list
- `.song-edit-btn` - Styles the edit button
- `.edit-song-form` - Styles the edit form
- `.edit-song-input` - Styles the title input field
- `.edit-song-textarea` - Styles the content textarea
- `.delete-btn` - Styles the delete button

## Status Messages
The edit modal displays status messages:
- **Info (blue)**: "Saving changes..." / "Deleting song..."
- **Success (green)**: "Song updated successfully!" / "Song deleted successfully!"
- **Error (red)**: Error messages if something goes wrong

## Important Notes

1. **Backup Recommended**: Although the delete function asks for confirmation, consider backing up important songs before deletion

2. **Active Song Selection**: If you edit or delete a currently selected song, the selection will be cleared after the operation

3. **Title Changes**: Changing a song's title creates a new file with a new filename, but the content is preserved

4. **Character Handling**: Special characters in titles are automatically converted to hyphens in the filename

5. **Concurrent Access**: If multiple operators are using the system, changes made by one operator will be visible to others after they refresh their song list

## Troubleshooting

### Edit button not appearing:
- Refresh the page
- Check that songs are loading correctly

### Changes not saving:
- Check the browser console for errors
- Verify the server is running
- Check file permissions on the songs directory

### Song list not refreshing:
- The list automatically refreshes after 1.5 seconds
- If it doesn't, manually refresh the page

## Future Enhancements (Potential)
- Undo functionality
- Bulk edit capability
- Song versioning/history
- Duplicate song feature
- Import/export individual songs
