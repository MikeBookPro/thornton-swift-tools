import Foundation

let arguments = ProcessInfo().arguments
if arguments.count < 3 {
    print("missing arguments")
}
let (input, output) = (arguments[1], arguments[2])

let jsonURL = URL(fileURLWithPath: input)
let json = try Data(contentsOf: jsonURL)
let swagger = try JSONDecoder().decode(SwaggerModel.self, from: json)

let baseURL = swagger.servers.first?.urlString ?? ""

let code = """
import Foundation
\(SwaggerModel.NetworkModel.string(for: swagger))

\(SwaggerModel.NetworkAPI.string(for: swagger))
"""
try code.write(to: URL(fileURLWithPath: output), atomically: true, encoding: .utf8)
