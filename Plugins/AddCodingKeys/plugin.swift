import Foundation
import PackagePlugin
//import Utilities

@main
struct AddCodingKeys: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // TODO: Replace this with actually creating the coding keys
        let process = Process()
        process.executableURL = .init(string: "/usr/bin/git")
        process.arguments = ["log", "--pretty=format: %an <%ae>%n"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        try process.run()
        process.waitUntilExit()
        
        guard let outputData = try outputPipe.fileHandleForReading.readToEnd() else { throw AddCodingKeyError.failedToReadFile }
        let output = String(decoding: outputData, as: UTF8.self)
        
        try Set(output.components(separatedBy: CharacterSet.newlines))
            .sorted()
            .filter(\.isEmpty.not)
            .joined(separator: "\n")
            .write(toFile: "CONTRIBUTORS.txt", atomically: true, encoding: .utf8)
    }
}

enum AddCodingKeyError: Error {
    case failedToReadFile
}

extension Bool {
    var not: Bool { !self }
}
