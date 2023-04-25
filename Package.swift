// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "thornton-swift-tools",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "thornton-swift-tools",
            targets: ["thornton-swift-tools", "Utilities"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "thornton-swift-tools",
            dependencies: []),
        .testTarget(
            name: "thornton-swift-toolsTests",
            dependencies: ["thornton-swift-tools"]),
        
        .target(name: "Utilities",
               dependencies: []),
        
        .plugin(
            name: "AddCodingKeys",
            capability: .command(
                intent: .custom(
                    verb: "add-coding-keys-to-codable",
                    description: "Adds the CodingKeys enumeration to the Codable element based on the element's instance properties"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Writes the CodingKeys enumeration for the provided Swift element.")
                ]
            ),
            dependencies: [
                "Utilities"
            ]
        ),
        
        .plugin(
            name: "GenerateContributors",
            capability: .command(
                intent: .custom(
                    verb: "generate-contributors-list",
                    description: "Generates the CONTRIBUTORS.txt file based on Git logs"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command writes the new CONTRIBUTORS.txt to the source root.")
                ]
            )),
    ]
)
