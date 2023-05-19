import Foundation
import SwiftUI

public enum NetworkServices {
  public final class ImageDownloader: NetworkDownloadServiceRepresentable {
    public typealias Item = Image

    public var taskCache: NetworkServices.TaskCache<Image> = .init()

    public static let shared: NetworkServices.ImageDownloader = .init()

    private init() {}
  }
}

