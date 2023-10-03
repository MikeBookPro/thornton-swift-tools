import SwiftUI

// MARK: - Content View

struct ContentView: View {

//  let items: [String] = Array(arrayLiteral: "one", "two", "three") // This will fail SwiftLint
  let items: [String] = ["one", "two", "three"]

  var body: some View {
    List {
      Image.circleHexagongridFill
        .resizable()
        .padding()
        .frame(width: 200.0, height: 200.0)

      ForEach(items, id: \.self) {
        Text($0)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
