# IM System (Python server + Qt client)

A lightweight instant messaging demo with:
- Python WebSocket server (`server.py`)
- Qt 6 cross-platform client for Windows/Android (`client_Qt/`)
- Windows installer automation using Inno Setup (`package/`)

## Project structure

- `server.py`: WebSocket server (login, user list, chat forwarding)
- `client.py`: simple Python CLI client for quick testing
- `client_Qt/`: Qt MVP client source code (QML + C++)
- `package/im.iss`: Inno Setup installer script
- `package/build_windows_installer.ps1`: one-command Windows installer build script

## Requirements

- Python 3.10+
- `pip install -r requirements.txt`
- Qt 6.8.x (MinGW kit for Windows build)
- Inno Setup 6 (for Windows installer packaging)

## Run server

```bash
python server.py --host 0.0.0.0 --port 8765
```

## Run Python CLI client (optional)

```bash
python client.py --server ws://127.0.0.1:8765
```

## Build Qt client (Windows)

Open `client_Qt/CMakeLists.txt` in Qt Creator and build `Release` with a Qt 6.8.x desktop kit.

## Build Windows installer (recommended)

From repo root:

```powershell
powershell -ExecutionPolicy Bypass -File package\build_windows_installer.ps1
```

Optional args:

```powershell
powershell -ExecutionPolicy Bypass -File package\build_windows_installer.ps1 `
  -Version "0.1.1" -Publisher "IMSystem" `
  -IsccPath "D:\Program Files\Inno Setup 6\ISCC.exe"
```

Output installer:
- `package/out/im.exe`

## Notes

- The installer script deploys Qt runtime and QML modules using `windeployqt --qmldir client_Qt`.
- Do not commit generated build artifacts; `.gitignore` is configured for common outputs.
