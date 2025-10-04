### Project Requirements: Church Presentation Web App

**1. Core Application Structure**
*   A single web application running on a local laptop using Python's built-in HTTP server.
*   Accessible over WiFi via the laptop's IP address (e.g., `http://[LAPTOP_IP]:8000`).
*   Two distinct HTML pages:
    *   Operator Control Page: `operator.html`
    *   Projector Display Page: `projector.html`
*   Real-time communication using native browser WebSocket API.

**2. Technology Stack**
*   **Backend:** Python's built-in `http.server` module
*   **Frontend:** Pure HTML, CSS, and Vanilla JavaScript
*   **Real-Time Communication:** Native WebSocket API
*   **Styling:** Plain CSS only
*   **Data Storage:** JSON files in `/songs/` directory

**3. Project Structure**
```
project-root/
├── index.html (default landing page)
├── operator.html
├── projector.html
├── css/
│   └── style.css
├── js/
│   ├── operator.js
│   ├── projector.js
│   └── websocket-server.js (or Python WebSocket server)
├── images/
│   └── church-logo.png
├── songs/
│   ├── song-1.json
│   ├── song-2.json
│   └── ...
└── server.py (WebSocket server script)
```

**4. Song Library & Management**
*   Songs are stored as JSON files in the `/songs/` directory.
*   The app must read and parse all songs from this folder.
*   Operator can search for songs by **Title** only.
*   Song file naming convention: lowercase with hyphens (e.g., `amazing-grace.json`).

**5. Song Lyrics Format**
*   Each song file contains the full lyrics in JSON format.
*   Lyrics are manually grouped into phrases during song file creation.
*   Example `song-title.json` structure:
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

**6. Default Screen**
*   When the application starts, the Projector Display shows a default "Welcome" screen.
*   This can be changed by the operator at any time.

**7. Operator Control Page (`operator.html`)**
*   **Primary View:** A searchable list of songs with live filtering.
*   **Song Selection:**
    *   Click a song to load its pre-defined phrases.
    *   Display the list of phrases for the selected song.
    *   Click on any phrase to instantly update the Projector Display.
*   **Simple Slides Control:**
    *   Buttons to display pre-defined slides on the projector:
        *   "Welcome"
        *   "Sermon in Progress"
        *   "Prayer Time"
        *   "Announcements"
        *   "Bible Verse" (with editable text field)
        *   "Blank Screen" (black screen)
*   **Display Settings:**
    *   Font size control (Small, Medium, Large, Extra Large buttons).
    *   Current selection indicator showing what's displayed on projector.

**8. Projector Display Page (`projector.html`)**
*   **Purpose:** A clean, full-screen view for congregation display.
*   **Content Display:**
    *   Shows current song phrase or selected simple slide.
    *   Lyrics/text centered vertically and horizontally on screen.
*   **Default Styling:**
    *   Background: White
    *   Text Color: Black
    *   Church logo (PNG) displayed in top-right corner (fixed position)
    *   Font size controlled by operator's selection
    *   Default font size: 48px (configurable)
*   **Behavior:**
    *   Page displays instructions to press F11 for full-screen mode on load.
    *   No controls, buttons, or navigation elements visible.
    *   Updates in real-time when operator selects new content.

**9. WebSocket Communication**
*   WebSocket server runs alongside HTTP server for real-time updates.
*   Server listens on a separate port (e.g., `ws://[LAPTOP_IP]:8765`).
*   Messages sent from operator to projector include:
    *   Content type: `song_phrase`, `simple_slide`, or `blank`
    *   Content text
    *   Font size setting
*   Projector page automatically reconnects if connection is established.

**10. Server Setup & Running**
*   **HTTP Server:** Run using `python -m http.server 8000`
*   **WebSocket Server:** Separate Python script using `websockets` library or simple implementation
*   Both servers start with a single command or batch/shell script.
*   Application accessible at `http://[LAPTOP_IP]:8000/index.html`

**11. Default Landing Page (`index.html`)**
*   Displays two clear buttons/links:
    *   "Open Operator Control" → Links to `operator.html`
    *   "Open Projector Display" → Links to `projector.html`
*   Shows local IP address and instructions for accessing from other devices.

**12. Font Size Options**
*   Small: 36px
*   Medium: 48px (default)
*   Large: 64px
*   Extra Large: 80px

**13. Simple Slide Content (Pre-defined)**
*   **Welcome:** "Welcome to [Church Name]"
*   **Sermon in Progress:** "Sermon in Progress"
*   **Prayer Time:** "Prayer Time"
*   **Announcements:** "Announcements"
*   **Bible Verse:** User can type custom text in operator page
*   **Blank Screen:** Solid black screen

**14. Technical Requirements**
*   All pages must work on modern browsers (Chrome, Firefox, Edge).
*   No internet connection required after initial setup.
*   Song list must load dynamically from `/songs/` directory.
*   Logo image path: `/images/church-logo.png`
*   Responsive text sizing based on selected font size.
*   Clean, minimal UI with clear labels and intuitive controls.

**15. Error Handling**
*   If WebSocket connection fails, show message on operator page.
*   If no songs found in `/songs/` directory, display appropriate message.
*   If logo image missing, display placeholder or text.

**16. Configuration**
*   WebSocket server address configurable in JavaScript files.
*   Default font size configurable in CSS or JavaScript constant.
*   Church name configurable for welcome slide.