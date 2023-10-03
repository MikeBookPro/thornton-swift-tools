import PackagePlugin

@main
struct GenerateTokenBuildTool: BuildToolPlugin {
    func createBuildCommand(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }
        return try target.sourceFiles(withSuffix: "xcassets").map { assetCatalog in
            let base = assetCatalog.path.stem
            let input = assetCatalog.path
            let output = context.pluginWorkDirectory.appending(["\(base).swift"])

            let exec = try context.tool(named: "AssetTokenGeneratorExec").path
            return .buildCommand(
                displayName: "Generating tokens for \(base).xcassets",
                executable: exec,
                arguments: [input.string, output.string],
                inputFiles: [input],
                outputFiles: [output]
            )
        }
    }
}
