Ollama integration plan

Goal
- Use a locally-running Ollama instance as the AI agent backend for PalmierPro on Windows.

Local setup (developer)
- Install Ollama on your Windows machine following official Ollama docs.
- Ensure the `ollama` binary is on your PATH or set the OLLAMA_PATH environment variable to the full path of the binary.

Usage
- The first-pass Swift client uses the local CLI. Example usage:

```swift
let client = OllamaClient()
let response = try await client.query(model: "llama2", prompt: "Hello from PalmierPro")
print(response)
```

Implementation notes
- The current implementation shells out to `ollama run <model> --prompt "..."` and returns stdout.
- Some Ollama versions or deployment setups expose an HTTP API; adding an HTTP-backed path (OLLAMA_URL) is a planned follow-up.
- If the installed ollama CLI uses different arguments, update `Sources/PalmierPro/Utilities/OllamaClient.swift` to match your local CLI.

Next steps
- Wire OllamaClient into the app's agent layer (Sources/PalmierPro/Agent).
- Add unit tests that mock Process output.
- If desired, add an HTTP fallback to call a local/remote Ollama HTTP server when available.
