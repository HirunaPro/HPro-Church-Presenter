# AGENTS.md

Guidance for AI coding agents working in this repo.

## What this is

Self-hosted church lyrics presenter. An operator (phone/laptop) picks a song phrase; a projector page shows it full-screen on another device on the same network. No cloud, no database.

## Architecture

- `src/server/server.py` runs two servers in one process:
  - `ThreadingHTTPServer` on `HTTP_PORT`/`PORT` (default 8000): static files, `/songs/`, JSON API.
  - `websockets` relay on `WEBSOCKET_PORT` (default 8765): a message from an authorized operator is re-broadcast to every other connected client (projectors). The relay only checks the message is valid JSON; it does not validate fields.
- Songs are JSON files in `src/songs/`, one per song. Filenames are Sinhala/Unicode slugs derived from the title (`generate_filename`), normalized to NFC. macOS stores NFD, so lookups match NFC/NFD variants (`safe_song_path`).
- Frontend is static HTML/CSS/JS in `src/static/`, served as-is.

## Key files

| Path | Purpose |
|---|---|
| `src/server/server.py` | HTTP API, static serving, WS relay, path safety, auth |
| `src/server/server-optimized.py` | Stale, slated for deletion (see `docs/PENDING.md`). Do not edit |
| `tests/test_server.py` | pytest suite (path safety, CRUD, auth, headers, WS relay) |
| `src/static/index.html`, `welcome.html` | Landing page, projector welcome screen (iframe) |
| `src/static/operator.html`, `js/operator.js` | Operator UI: song list, phrases, editor, import/export, shortcuts |
| `src/static/projector.html`, `js/projector.js` | Projector display, auto font fitting, transitions |
| `src/static/js/transliteration.js` | Transliteration helper for the editor |
| `deployment/native/` | PyInstaller spec + `build.sh` / `build.ps1` |
| `deployment/docker/` | `Dockerfile`, `docker-compose.yml` |
| `.github/workflows/build.yml` | CI: tests, native builds, release on `v*` tags |
| `start.bat`, `startup.sh` | Convenience launchers (Windows, macOS/Linux) |

## HTTP API

- `GET /api/config` -> `{"wsPort": int, "authRequired": bool}`
- `GET /songs/` -> sorted JSON array of NFC filenames; `GET /songs/<name>.json` -> song file
- `POST /api/save-songs` `{songs:[{title,...}]}` -> `{success,saved,skipped,total}`. Existing titles are skipped, not overwritten.
- `POST /api/update-song` `{oldFilename, song}` -> `{success, filename}`. The file is renamed when the title changes; 409 if the target exists.
- `POST /api/delete-song` `{filename}` -> `{success, message}`
- Errors: `{success:false, message}` with 400/401/404/409/413/500. Body must be a JSON object with a valid `Content-Length`, max 5 MiB.
- Auth: if `OPERATOR_KEY` is set, all `POST /api/*` need the `X-Operator-Key` header (401 otherwise). GETs are open. If unset, everything is open and the server prints a warning.

## WebSocket messages

JSON text frames. Operator connects with `ws://host:<wsPort>/?key=<OPERATOR_KEY>`. Clients without a valid key are view-only: they receive but their messages are dropped. Projector fields (from `operator.js` / `projector.js`):

- `{type:"song_phrase", text, fontSize, songTitle, nextVersePreview}`
- `{type:"simple_slide", text, fontSize}`
- `{type:"blank", text:"", fontSize}`
- `{type:"welcome_screen", text}`
- `fontSize` is a class suffix (`font-<value>`, default `medium`) or `auto`, which fits text to the screen.

## Setup, test, run

```bash
python3.11+ -m venv .venv        # use any python >= 3.11 (runtime.txt pins 3.14)
.venv/bin/pip install -r requirements-dev.txt
.venv/bin/python -m pytest tests
.venv/bin/python src/server/server.py     # then open http://localhost:8000/index.html
OPERATOR_KEY=secret .venv/bin/python src/server/server.py   # with auth
```

Env vars: `HTTP_PORT`/`PORT`, `WEBSOCKET_PORT`, `OPERATOR_KEY`, `STATIC_DIR`, `SONGS_DIR`.

Native build (PyInstaller, output in `dist/`):
```bash
PYTHON=python3.14 ./deployment/native/build.sh     # macOS/Linux -> dist/church-presenter-<os>-<arch>.tar.gz
./deployment/native/build.ps1                      # Windows -> .zip (honors $env:PYTHON)
```
Docker: `cd deployment/docker && OPERATOR_KEY=... docker compose up` (ports 8000, 8765; mounts `src/songs`).

## Conventions and rules

- Frontend: vanilla JS/CSS only. No frameworks, no bundler, no build step.
- Server: Python stdlib plus `websockets` only. Adding a dependency needs a strong reason (it also affects the PyInstaller and Docker builds).
- Never put song or user data into `innerHTML`. Use `textContent` / `createElement`. (Existing `innerHTML` uses are static markup only; don't extend them with data.)
- Every song file access must go through `safe_song_path` (blocks traversal, symlink escape, non-`.json`, hidden files). Write with `write_json_atomic`.
- Frozen (PyInstaller) mode: static assets come from `sys._MEIPASS`; songs live in a writable `songs/` next to the executable, seeded from the bundle on first run (`seed_songs`). Keep new data files in the `.spec` `datas` list.
- Cache headers are deliberately `no-cache` for HTML/JS/CSS, `/api/`, and `/songs/` because assets are unversioned. Don't add long-lived caching.
- Keep tests passing. Add tests in `tests/test_server.py` for any server change (fixtures there start a real server and WS relay).
- Match the existing style of the surrounding code; keep diffs small.

## Git

- Conventional Commits with a required scope: `type(scope): description` (e.g. `feat(projector): ...`).
- Never commit build outputs or local environments: `dist/`, `build/`, `build-dist/`, `*.exe`, archives (`.zip`, `.tar.gz`), venvs (`.venv`, `.venv-build`). Never commit secrets or `.env` files.
- Releases: GitHub Actions builds per-OS artifacts and publishes them as separate assets on `v*` tags. Do not build or upload releases by hand.

## Pending work

See `docs/PENDING.md` (open items only; remove items when done).
