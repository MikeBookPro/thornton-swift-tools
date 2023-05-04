// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "thornton-swift-tools",
    platforms: [
        .macOS("12.0")
//        .macOS("13.3.1")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
//        .library(name: "thornton-swift-tools", targets: ["thornton-swift-tools"]),
        .library(name: "IconLibrary", targets: ["IconLibrary"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(url: "https://github.com/apple/swift-syntax.git", from: "508.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
//        .target(name: "thornton-swift-tools", dependencies: []),
        
        // MARK: - Plugin : Generate Contributors
        .plugin(
            name: "GenerateContributors",
            capability: .command(
                intent: .custom(
                    verb: "regenerate-contributors-list",
                    description: "Generates the CONTRIBUTORS.txt file based on Git logs"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command writes the new CONTRIBUTORS.txt to the source root.")
                ]
            )
        ),
        
        // MARK: - Swagger Model Generation
        .plugin(
            name: "GenerateSwaggerModels",
            capability: .buildTool(),
            dependencies: ["SwaggerModelGenExec"]
        ),
        .executableTarget(name: "SwaggerModelGenExec"),
        
        // MARK: - NetworkDownloadServices
        .target(
            name: "NetworkDownloadServices",
            dependencies: []
        ),
        
        
        // MARK: - Icon Library
        .target(
            name: "IconLibrary",
            dependencies: [
                "NetworkDownloadServices"
            ],
            plugins: [
                "GenerateAssetConstants",
                "GenerateSwaggerModels"
            ]
        ),
        .plugin(
            name: "GenerateAssetConstants",
            capability: .buildTool(),
            dependencies: ["AssetConstantsExec"]
        ),
        .executableTarget(name: "AssetConstantsExec"),
        
//        .executableTarget(
//            name: "AddCodingKeysExecutable",
//            dependencies: [
//                .product(name: "SwiftSyntax", package: "swift-syntax"),
//            ]
//        ),
    ]
)
