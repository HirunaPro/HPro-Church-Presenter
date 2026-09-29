# Pending Tasks

Open work only. Remove items when done.

## Maintenance

- [ ] Delete unused `src/server/server-optimized.py` (replaced by `src/server/server.py`)
- [ ] Verify Docker image builds and runs (`cd deployment/docker && docker compose up`)
- [ ] Verify CI native builds on Windows, macOS Intel (`macos-15-intel` runner label) and Linux, then cut the first `v*` release
- [ ] Add a `favicon.ico` (currently 404s)

## Operator UI

- [ ] Keyboard shortcuts (next/previous phrase, switch tabs)
- [ ] Remember last active tab
- [ ] Swipe gestures (switch tabs, navigate phrases)
- [ ] Full-screen phrase view on mobile
- [ ] History of recently displayed content
- [ ] Favourite/bookmarked songs
- [ ] Dark mode / custom theme colours
- [ ] PWA / offline support (service worker)
- [ ] Bluetooth presenter remote support

## Projector

- [ ] Toggle song-title visibility from the operator panel
- [ ] Configurable title position and styling
- [ ] Verse/chorus labels
- [ ] More transition styles (slide, cross-fade, zoom) and configurable speed

## Song Management

- [ ] Undo for edits and deletes
- [ ] Duplicate song
- [ ] Bulk edit
- [ ] Song version history
- [ ] Export selected songs only
- [ ] Import from CSV/XML; drag-and-drop import
- [ ] Merge (instead of skip) duplicates on import
