Windows 11 build notes

- This branch (windows-11-ollama-port) targets Windows (Windows 11 recommended). Use this branch to iterate on Windows porting.
- Install the official Swift toolchain for Windows and ensure `swift` is available in your PATH.
- Build with:

    swift build

- Ollama integration:
    - Install Ollama on your Windows machine and ensure the `ollama` binary is on PATH or set OLLAMA_PATH to its full path.
    - The repo includes a first-pass CLI-based client at `Sources/PalmierPro/Utilities/OllamaClient.swift`.

Notes & TODOs
- This initial commit updates the Swift package manifest and adds a CLI-based Ollama client. Many macOS-specific UI components and dependencies still need porting or replacement.
- Replace macOS-only dependencies and UI code (AppKit/UIKit) before expecting a working GUI on Windows.
