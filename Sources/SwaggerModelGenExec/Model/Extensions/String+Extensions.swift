extension String {
    var lowercasedFirstCharacter: String {
        (self.isEmpty) ? self : String(self.prefix(1).lowercased() + self.dropFirst())
    }
    
    func replacing(templates: [(target: String, replacement: String)]) -> String {
        templates.reduce(self) { partialResult, input in
            partialResult.replacingOccurrences(of: input.target, with: input.replacement)
        }
    }
}
