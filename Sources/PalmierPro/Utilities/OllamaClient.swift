import Foundation

/// Simple first-pass Ollama client that shells out to the local `ollama` binary.
///
/// Behavior:
/// - If the OLLAMA_PATH environment variable is set it will be used as the path to the binary, otherwise `ollama` is used and must be on PATH.
/// - Runs `ollama run <model> --prompt "..."` and returns stdout as a String.
///
/// Notes:
/// - This is a pragmatic first step to allow local development on Windows with a locally-installed Ollama binary.
/// - The exact CLI flags used by ollama may differ depending on the installed version; adjust the arguments in `runCLI` if needed.
public struct OllamaClient {
    public var binaryPath: String

    public init() {
        if let envPath = ProcessInfo.processInfo.environment["OLLAMA_PATH"], !envPath.isEmpty {
            self.binaryPath = envPath
        } else {
            self.binaryPath = "ollama"
        }
    }

    /// Query the local ollama binary for a single prompt.
    /// - Parameters:
    ///   - model: model name (e.g. "llama2")
    ///   - prompt: prompt string
    /// - Returns: the raw stdout from the ollama process
    public func query(model: String, prompt: String, timeoutSeconds: Int = 60) async throws -> String {
        return try await withCheckedThrowingContinuation { cont in
            do {
                let output = try runCLI(model: model, prompt: prompt, timeoutSeconds: timeoutSeconds)
                cont.resume(returning: output)
            } catch {
                cont.resume(throwing: error)
            }
        }
    }

    enum OllamaError: Error {
        case binaryNotFound(String)
        case processFailed(Int32, String)
        case timeout
    }

    private func runCLI(model: String, prompt: String, timeoutSeconds: Int) throws -> String {
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        // Use the binary path (may be just "ollama" if on PATH)
        process.executableURL = URL(fileURLWithPath: binaryPath)

        // Arguments: use `run <model> --prompt "..."`
        process.arguments = ["run", model, "--prompt", prompt]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
        } catch {
            throw OllamaError.binaryNotFound(binaryPath)
        }

        // Wait with a timeout
        let start = Date()
        while process.isRunning {
            Thread.sleep(forTimeInterval: 0.05)
            if Date().timeIntervalSince(start) > TimeInterval(timeoutSeconds) {
                process.terminate()
                throw OllamaError.timeout
            }
        }

        let status = process.terminationStatus
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdoutStr = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderrStr = String(data: stderrData, encoding: .utf8) ?? ""

        if status == 0 {
            return stdoutStr
        } else {
            throw OllamaError.processFailed(status, stderrStr)
        }
    }
}
