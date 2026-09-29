# Native builds (Windows, macOS, Linux)

Each OS is built on that OS (PyInstaller does not cross-compile). The result is an
onedir bundle: `church-presenter/` containing the executable, `static/` assets and a
`songs/` folder. Onedir is used instead of onefile because it starts instantly (no
extraction per launch), is less likely to trigger antivirus, and keeps `songs/`
writable next to the executable.

## Build

macOS / Linux (Python 3.11+):

    ./deployment/native/build.sh

Windows (PowerShell):

    powershell -ExecutionPolicy Bypass -File deployment\native\build.ps1

Output: `dist/<os>-<arch>/church-presenter/` plus `dist/church-presenter-<os>-<arch>.tar.gz` (`.zip` on Windows).
Set `PYTHON` to pick an interpreter and `VENV_DIR` to relocate the build venv (default `.venv-build`).

Builds are **never committed to git** (`dist/` is gitignored). They're published as separate GitHub Release assets, one per platform:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

CI (`.github/workflows/build.yml`) then builds on Windows, macOS (arm64 + Intel) and Linux and attaches `church-presenter-v1.0.0-<os>-<arch>.zip|.tar.gz` to the `v1.0.0` release.

To upload a locally built asset to an existing release instead:

```bash
gh release upload v1.0.0 dist/church-presenter-macos-arm64.tar.gz
```

## Run

Extract the archive, then:

- Windows: `church-presenter\church-presenter.exe`
- macOS / Linux: `./church-presenter/church-presenter`

Open `http://localhost:8000/index.html`. Ports: HTTP 8000, WebSocket 8765
(override with `HTTP_PORT`/`PORT`, `WEBSOCKET_PORT`).

## Firewall / network access

Other devices on the LAN need inbound access to TCP 8000 and 8765.

- Windows (Administrator PowerShell):

      netsh advfirewall firewall add rule name="Church Presenter HTTP" dir=in action=allow protocol=TCP localport=8000
      netsh advfirewall firewall add rule name="Church Presenter WS" dir=in action=allow protocol=TCP localport=8765

- macOS: click "Allow" on the "accept incoming network connections" prompt, or add the
  binary under System Settings > Network > Firewall.
- Linux: e.g. `sudo ufw allow 8000/tcp && sudo ufw allow 8765/tcp`.

## Unsigned binaries

- macOS Gatekeeper blocks downloaded unsigned binaries:
  `xattr -dr com.apple.quarantine church-presenter`
- Linux: `chmod +x church-presenter/church-presenter` if the executable bit was lost.
- Windows SmartScreen: "More info" > "Run anyway".
