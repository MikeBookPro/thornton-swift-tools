import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif


public protocol DataInitializable {
  init?(data: Data)
}

extension Image: DataInitializable {
  public init?(data: Data) {
#if os(macOS)
    guard let nsImage = NSImage(data: data) else { return nil }
    self = Image(nsImage: nsImage)
#elseif os(iOS)
    guard let uiImage = UIImage(data: data) else { return nil }
    self = Image(uiImage: uiImage)
#endif
  }
}

extension DataInitializable where Self: Decodable {
  public init?(data: Data) {
    guard let decoded = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
    self = decoded
  }
}

