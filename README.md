# Church Presenter

Self-hosted lyrics presenter for church services. An operator picks a song on a phone, tablet or laptop, and the words appear instantly on the projector screen. It runs over your local WiFi and needs no internet. Sinhala, Tamil and English songs are supported.

## Quick start

Pick one option.

### A. Download the app (easiest, no Python needed)

1. Download the file for your computer from the [GitHub Releases](../../releases) page (Windows, macOS or Linux).
2. Extract it, then run:
   - Windows: `church-presenter\church-presenter.exe` (if SmartScreen warns, click "More info", then "Run anyway")
   - macOS: first run `xattr -dr com.apple.quarantine church-presenter`, then `./church-presenter/church-presenter`
   - Linux: `chmod +x church-presenter/church-presenter`, then `./church-presenter/church-presenter`

Details: [deployment/native/README.md](deployment/native/README.md)

### B. Run from source (Python 3.11 or newer)

- Windows: double-click `start.bat`
- macOS / Linux: `./startup.sh`

Details: [deployment/local/README.md](deployment/local/README.md)

### C. Docker

```bash
cd deployment/docker
docker-compose up
```

Details: [deployment/docker/README.md](deployment/docker/README.md)

When the server starts it prints the addresses to use, for example `http://192.168.1.100:8000/index.html`.

## Using it during a service

1. Start the server on the computer that will stay on for the service.
2. On the operator device (phone, tablet or laptop on the same WiFi), open the printed address.
3. On the projector computer, open `http://<server-address>:8000/projector.html` and press F11 for full screen.
4. On the operator page, search for a song, select it, then click a phrase to show it on the projector.

| Page | Address | Who uses it |
| ---- | ------- | ----------- |
| Landing | `/index.html` | Everyone: links to the other pages |
| Operator | `/operator.html` | Person running the service |
| Projector | `/projector.html` | The projector computer |

Quick reference for the operator screen: [docs/UI-QUICK-REFERENCE.md](docs/UI-QUICK-REFERENCE.md). Fuller walkthrough: [docs/QUICK-START.md](docs/QUICK-START.md).

## Songs

Songs are JSON files in the `songs` folder (`src/songs` when running from source, `songs` next to the executable in a native build). You can add, edit and import songs from the operator page. To write a song file by hand, see [docs/MULTI-LINE-SONG-FORMAT.md](docs/MULTI-LINE-SONG-FORMAT.md).

Search works with English letters: typing `yesu` or `oba` finds Sinhala and Tamil songs. See [docs/SINGLISH-SEARCH.md](docs/SINGLISH-SEARCH.md).

## Security

By default there is no login. Anyone on the same network can control the projector and edit or delete songs. Set `OPERATOR_KEY` to require a key for changes:

| Platform | How to set it |
| -------- | ------------- |
| Windows (cmd) | `set OPERATOR_KEY=my-secret` then run `start.bat` |
| Windows (PowerShell) | `$env:OPERATOR_KEY="my-secret"` then run the app |
| macOS / Linux | `OPERATOR_KEY=my-secret ./startup.sh` |
| Docker | `OPERATOR_KEY=my-secret docker-compose up` |

Use a long random value. Only use the app on a network you trust. Do not expose it to the internet: there is no HTTPS, so if you must, put it behind a TLS reverse proxy and set `OPERATOR_KEY`.

## Configuration

All settings are optional environment variables.

| Variable | Default | Purpose |
| -------- | ------- | ------- |
| `HTTP_PORT` (or `PORT`) | `8000` | Web page port |
| `WEBSOCKET_PORT` | `8765` | Live update port |
| `OPERATOR_KEY` | empty (no auth) | Key required for changes |
| `SONGS_DIR` | `src/songs` | Where song files are stored |
| `STATIC_DIR` | `src/static` | Where the web pages are served from |

### Welcome screen

Edit `src/static/welcome.json` to set the welcome slide text. All fields are optional; empty ones are hidden.

```json
{ "title": "Welcome", "subtitle": "Family Camp", "year": "2026",
  "message": "A short verse or message", "reference": "Isaiah 42:3",
  "logo": "images/logo.png" }
```

## Troubleshooting

**Other devices cannot connect.** Make sure every device is on the same WiFi (not a guest network) and use the server's IP address, not `localhost`. Allow TCP ports 8000 and 8765 through the server's firewall. Windows example, in an Administrator PowerShell:

```
netsh advfirewall firewall add rule name="Church Presenter HTTP" dir=in action=allow protocol=TCP localport=8000
netsh advfirewall firewall add rule name="Church Presenter WS" dir=in action=allow protocol=TCP localport=8765
```

On Linux use `sudo ufw allow 8000/tcp && sudo ufw allow 8765/tcp`. On macOS click "Allow" when prompted.

**Projector does not update.** Reload the projector page and check that the operator and projector show as connected. Port 8765 must be reachable from the projector computer. If you set `OPERATOR_KEY`, make sure the operator page has the correct key.

**Songs are missing.** Check that the `songs` folder contains `.json` files and that `SONGS_DIR` (if set) points to it. In Docker, the songs folder must be mounted as a volume.

**Port already in use.** Close the other copy of the app, or set `HTTP_PORT` and `WEBSOCKET_PORT` to free ports.

**Page looks old after an update.** Hard refresh with Ctrl+Shift+R (Cmd+Shift+R on Mac).

Docker-specific problems: [docs/DOCKER-TROUBLESHOOTING.md](docs/DOCKER-TROUBLESHOOTING.md)

## For developers

Layout:

- `src/server/server.py`: HTTP and WebSocket server (Python)
- `src/static/`: operator and projector pages (vanilla JS, CSS)
- `src/songs/`: song JSON files
- `deployment/`: local, Docker and native build guides and scripts
- `tests/`: pytest suite

Run tests:

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
pytest
```

Build a native package locally: see [deployment/native/README.md](deployment/native/README.md). Releases are built by CI when you push a `v*` tag (for example `git tag v1.0.0 && git push origin v1.0.0`). Build outputs are never committed.

More: [AGENTS.md](AGENTS.md), [docs/PROJECT-STRUCTURE.md](docs/PROJECT-STRUCTURE.md), [docs/PENDING.md](docs/PENDING.md).
