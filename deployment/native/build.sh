#!/usr/bin/env bash
# Build a native bundle for the current macOS/Linux machine.
# Output: dist/<os>-<arch>/church-presenter/ and dist/church-presenter-<os>-<arch>.tar.gz
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
[ "$OS" = "darwin" ] && OS="macos"
ARCH="$(uname -m)"; [ "$ARCH" = "aarch64" ] && ARCH="arm64"; [ "$ARCH" = "x86_64" ] && ARCH="x64"
TARGET="$OS-$ARCH"

VENV="${VENV_DIR:-$ROOT/.venv-build}"
PY="${PYTHON:-python3}"
"$PY" -m venv "$VENV"
"$VENV/bin/python" -m pip install --upgrade pip
"$VENV/bin/python" -m pip install -r requirements-build.txt

rm -rf "dist/$TARGET" "build/native/$TARGET"
"$VENV/bin/python" -m PyInstaller --noconfirm --clean \
  --distpath "dist/$TARGET" --workpath "build/native/$TARGET" \
  deployment/native/church-presenter.spec

tar -C "dist/$TARGET" -czf "dist/church-presenter-$TARGET.tar.gz" church-presenter
echo "Built dist/$TARGET/church-presenter and dist/church-presenter-$TARGET.tar.gz"
