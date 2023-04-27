import Foundation

let arguments = ProcessInfo().arguments
if arguments.count < 3 {
    print("missing arguments")
}
let (input, output) = (arguments[1], arguments[2])

// MARK: - Contents
struct Contents: Decodable {
    let images: [Image]
}

// MARK: - Image
struct Image: Decodable {
    let filename: String?
}

var generatedCode = """
    import Foundation
    import SwiftUI
    
    // arguments[1] \(input)
    // arguments[2] \(output)
    
    extension Image {
    
    """
var dirents: [String] = []
try FileManager.default.contentsOfDirectory(atPath: input).forEach { dirent in
    dirents.append(dirent)
    
    guard dirent.hasSuffix("imageset") else { return }
    
    let jsonURL = URL(fileURLWithPath: "\(input)/\(dirent)/Contents.json")
    let json = try Data(contentsOf: jsonURL)
    let assetCatalogContents = try JSONDecoder().decode(Contents.self, from: json)
    
    let hasImage = !(assetCatalogContents.images.filter { $0.filename != nil }.isEmpty)
    
    if hasImage {
        let basename = jsonURL
            .deletingLastPathComponent()
            .deletingPathExtension()
            .lastPathComponent
        
        generatedCode.append("\tpublic static let \(basename) = Image(\"\(basename)\", bundle: .module)\n")
    }
    
}
generatedCode.append("""
}
/*
// dirents:
//  - \(dirents.joined(separator: "\n //\t - "))
*/
""")
try generatedCode.write(to: URL(fileURLWithPath: output), atomically: true, encoding: .utf8)
