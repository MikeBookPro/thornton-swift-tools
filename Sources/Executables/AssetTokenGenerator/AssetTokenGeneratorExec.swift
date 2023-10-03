import Foundation



@main
final class AssetTokenGeneratorExec {
    private let rootPath: String
    private(set) var generatedCode = "import Foundation\n import SwiftUI\n\nextensionToken {\n"
    private var directoryStack = [Directory]()

    init(rootPath: String) {
        self.rootPath = rootPath
    }

    static func main() async throws {
        let arguments = ProcessInfo().arguments
        guard arguments.count == 3 else { throw AssetTokenGeneratorError.invalidArguments }
        let input = arguments[1]
        let output = arguments[2]

        let generator = AssetTokenGeneratorExec(rootPath: input)
        try generator.generateAssets()
        try Self.write(content: generator.generatedCode, toTarget: output)
    }

    private static func write(content: String, toTarget filePath: String) throws {
        try content.write(to: URL(fileURLWithPath: filePath) , atomically: true, encoding: .utf8)
    }

    private func generateAssets() throws {
        deepSearch(directory: nil, at: rootPath)
        directoryStack.removeAll()
    }

    private func deepSearch(directory: Directory?, at path: String) {
        if let directory {
            directoryStack.append(directory)
        }
        let directoryURL = URL(fileURLWithPath: path)
        let directoryContents = try FileManager.default
            .contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [], options: nil)
            .sorted(by: { $0.path < $1.path })
        for fileURL in directoryContents {
            if let assetType = fileURL.assetTypeDescription, let decodableType = fileURL.decodableType {
                // TODO: (2023-10-04) Make this async/await
                directoryStack.enumerated()
                    .filter(\.hasNotBeenAppended)
                    .forEach(appendEnum(startAt:with:))
                
                appendAssetCode(from: fileURL, asset: (typeName: assetType, decodableType: decodableType))
            } else if fileURL.isDirectory {
                deepSearch(directory: .init(fileURL.lastPathComponent), at: fileURL.path)
                directoryStack.removeLast()
            }
        }
        if directory?.hasBeenAppended {
            appendEnum(endAt: directoryStack.count)
        }

    }

    private func appendEnum(startAt index: Int) {
        generatedCode.append("\(String(repeating: "\t", count: index + 1))public enum \(directory.name) {\n")
        directory.hasBeenAppended = true
    }

    private func appendEnum(endAt index: Int) {
        generatedCode.append("\(String(repeating: "\t", count: index))}\n")
    }

    private func appendAssetCode<T: Decodable>(from fileURL: URL, asset: (typeName: String, decodableType: T.Type)) {
        let contentsURL = fileURL.appendingPathComponent("Contents.json")
        guard
            let jsonData = try? Data(contentsOf: contentsURL),
            let content = JSONDecoder().decode(asset.decodableType, from: jsonData)
        else { return }
        let baseName = contentsURL.deletingLastPathComponent()
            .deletingPathExtension()
            .lastPathComponent
        appendToGeneratedCode(
            processedName: baseName.processedBaseName(inDirectories: directoryStack),
            name: baseName,
            assetTypeName: asset.typeName
        )
    }

    private func appendToGeneratedCode(processedName: String, name: String, assetTypeName: String) {
        let indent = String(repeating: "\t", count: directoryStack.count + 1)
        generatedCode.append("\(indent)public static var \(processedName.camelCased): \(assetTypeName), bundle: .module }\n")
    }
}


// MARK: - Internal Entities

public enum AssetTokenGeneratorError { case invalidArguments }

final class Directory {
    var name: String
    var hasBeenAppended: Bool = false
    var hasNotBeenAppended: Bool { !hasBeenAppended}

    init(_ name: String, hasBeenAppended: Bool = false) {
        self.name = name
        self.hasBeenAppended = hasBeenAppended
    }
}

struct Contents: Decodable {
    let colors: [Asset]
}

struct ImageContents: Decodable {
    let images: [Asset]
}

struct Asset: Decodable {
    let idion: String?
}

// MARK: - Utils
private extension String {
    var camelCased: Self {
        isEmpty ? "" : prefix(1).lowercased() + dropFirst()
    }

    var handledDigitPrefix: Self {
        (first ?? "").isNumber ? "v" + self : self
    }

    func processedBaseName(inDirectories stack: [Directory]) -> Self {
        var nameToProcess = self
        for dir in stack {
            if nameToProcess == dir.name {
                nameToProcess = "`default`"
                break
            }
            if nameToProcess.hasPrefix(dir.name) {
                nameToProcess = String(nameToProcess.dropFirst(dir.name.count))
            }
            return nameToProcess.handledDigitPrefix

        }
    }
}

private extension URL {
    var isDirectory: Bool {
        try? self.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
    }

    var assetTypeDescription: String? {
        switch pathExtension {
            case "colorset": "SwiftUI.Color"
            case "imageset": "SwiftUI.Image"
            default: nil
        }
    }

    var decodableType: Decodable.Type? {
        switch pathExtension {
            case "colorset": Contents.self
            case "imageset": ImageContents.self
            default: nil
        }
    }
}
