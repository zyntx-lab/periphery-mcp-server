import Foundation

/// Utility for executing Periphery commands
struct PeripheryRunner {
    /// Default timeout for Periphery scans (5 minutes)
    static let defaultTimeout: TimeInterval = 300

    /// Finds the path to the Periphery executable
    /// - Returns: Path to Periphery or nil if not found
    static func findPeripheryPath() -> String? {
        // Common installation paths
        let possiblePaths = [
            "/usr/local/bin/periphery",
            "/opt/homebrew/bin/periphery",
            "/usr/bin/periphery"
        ]

        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        // Try using 'which' command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["periphery"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !path.isEmpty {
                    return path
                }
            }
        } catch {
            return nil
        }

        return nil
    }

    /// Checks if Periphery is installed
    /// - Returns: True if Periphery is installed
    static func isPeripheryInstalled() -> Bool {
        return findPeripheryPath() != nil
    }

    /// Executes a Periphery command with the given arguments
    /// - Parameters:
    ///   - arguments: Command-line arguments to pass to Periphery
    ///   - timeout: Maximum execution time in seconds (default: 300)
    /// - Returns: The standard output from Periphery
    /// - Throws: PeripheryError if execution fails
    static func execute(
        _ arguments: [String],
        timeout: TimeInterval = defaultTimeout
    ) async throws -> String {
        guard let peripheryPath = findPeripheryPath() else {
            throw PeripheryError.notInstalled
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: peripheryPath)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Start the process
        try process.run()

        // Implement timeout handling
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            if process.isRunning {
                process.terminate()
            }
        }

        // Wait for process to complete
        process.waitUntilExit()
        timeoutTask.cancel()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        // Check if process was terminated due to timeout
        if process.terminationReason == .uncaughtSignal ||
           (process.terminationStatus == 15 && !process.isRunning) {
            throw PeripheryError.timeout
        }

        // Check for execution errors
        if process.terminationStatus != 0 {
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw PeripheryError.executionFailed(errorMessage)
        }

        return String(data: outputData, encoding: .utf8) ?? ""
    }

    /// Gets the version of the installed Periphery
    /// - Returns: Version string
    /// - Throws: PeripheryError if version cannot be determined
    static func getVersion() async throws -> String {
        let output = try await execute(["version"])
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
