import SwiftUI

// MARK: - Content View

struct ContentView: View {
    var body: some View {
        Image.circleHexagongridFill
            .resizable()
            .padding()
            .frame(width: 200.0, height: 200.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
