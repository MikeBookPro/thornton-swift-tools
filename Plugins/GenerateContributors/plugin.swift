import Foundation
import PackagePlugin

@main
struct GenerateContributors: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    let process = Process()
    process.executableURL = Bundle.main.url(forAuxiliaryExecutable: "/usr/bin/git") // URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = ["log", "--pretty=format:- %an <%ae>%n"]

    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    try process.run()
    process.waitUntilExit()

    guard let outputData = try outputPipe.fileHandleForReading.readToEnd() else { throw GenerateContributorsError.failedToReadFile }
    let output = String(decoding: outputData, as: UTF8.self)
    try Set(output.components(separatedBy: CharacterSet.newlines))
      .filter { !$0.isEmpty }
      .sorted()
      .joined(separator: "\n")
      .write(toFile: "CONTRIBUTORS.txt", atomically: true, encoding: .utf8)
  }
}

enum GenerateContributorsError: Error {
  case failedToReadFile
}

extension Bool {
  var not: Bool { !self }
}

/*
 Create a Swift Package Plugin

 Xcode code snippet that can be used inside a swift class
 or struct to create the CodingKeys enum for that class and
 auto populates cases for each instance property of that class/struct.
 */

