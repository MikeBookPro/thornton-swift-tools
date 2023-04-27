import Foundation

let arguments = ProcessInfo().arguments
if arguments.count < 3 {
    print("missing arguments")
}
let (input, output) = (arguments[1], arguments[2])

let jsonURL = URL(fileURLWithPath: input)
let json = try Data(contentsOf: jsonURL)
let swagger = try JSONDecoder().decode(SwaggerModel.self, from: json)

let code = swagger.components.swiftCode.joined(separator: "\n")
try code.write(to: URL(fileURLWithPath: output), atomically: true, encoding: .utf8)


//FileManager.default.fileExists(atPath: input)
//try FileManager.default.contentsOfDirectory(atPath: input).forEach { fileName in
//    guard fileName.hasSuffix(".json") else { return } // imageset
//
//    let jsonURL = URL(fileURLWithPath: "\(input)/\(fileName)") // Contents.json
//
//
//    try swagger.components.swiftCode.forEach { (fileName, code) in
//        try code.write(to: URL(fileURLWithPath: output), atomically: true, encoding: .utf8)
//    }
//
//}
////generatedCode.append("}")
//try generatedCode.write(to: URL(fileURLWithPath: output), atomically: true, encoding: .utf8)
