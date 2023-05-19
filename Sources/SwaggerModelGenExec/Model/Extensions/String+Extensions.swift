extension String {
  var lowercasedFirstCharacter: String {
    (self.isEmpty) ? self : String(self.prefix(1).lowercased() + self.dropFirst())
  }

  func replacing(templates: [(target: String, replacement: String)]) -> String {
    templates.reduce(self) { partialResult, input in
      partialResult.replacingOccurrences(of: input.target, with: input.replacement)
    }
  }

  static let alphabeticalPrefixThenDigitOrder: (String, String) -> Bool = { lhs, rhs in
    let lhsPrefix = lhs.prefix(while: { $0.isLetter })
    let rhsPrefix = rhs.prefix(while: { $0.isLetter })

    if lhsPrefix == rhsPrefix {
      let lhsNumber = Int(lhs.dropFirst(lhsPrefix.count)) ?? 0
      let rhsNumber = Int(rhs.dropFirst(rhsPrefix.count)) ?? 0
      return lhsNumber < rhsNumber
    } else {
      return lhs < rhs
    }
  }
}

