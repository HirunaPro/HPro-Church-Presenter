# PyInstaller spec: onedir build (fast startup, no per-launch extraction,
# songs can live in a writable folder next to the executable).
from pathlib import Path

root = Path(SPECPATH).resolve().parents[1]

a = Analysis(
    [str(root / 'src' / 'server' / 'server.py')],
    pathex=[str(root / 'src' / 'server')],
    datas=[
        (str(root / 'src' / 'static'), 'static'),
        (str(root / 'src' / 'songs'), 'songs'),
    ],
    hiddenimports=[
        'websockets',
        'websockets.legacy',
        'websockets.legacy.server',
        'websockets.legacy.client',
    ],
    excludes=['tkinter', 'unittest', 'pytest'],
)
pyz = PYZ(a.pure)
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='church-presenter',
    console=True,
    upx=False,
)
coll = COLLECT(exe, a.binaries, a.datas, name='church-presenter', upx=False)
