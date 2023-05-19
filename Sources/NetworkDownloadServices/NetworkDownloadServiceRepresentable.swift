import Foundation

public protocol NetworkDownloadServiceRepresentable: AnyObject {
  associatedtype Item: DataInitializable

  var taskCache: NetworkServices.TaskCache<Item> { get }

  func fetch(for urlRequest: URLRequest) async throws -> Item?

  func fetch(from url: URL?) async throws -> Item?

  static func downloadItem(for urlRequest: URLRequest) async throws -> Item

  static func downloadItem(from url: URL) async throws -> Item

  func prefetch(itemsFrom urls: [URL]) throws

}

public extension NetworkDownloadServiceRepresentable {
  func fetch(for urlRequest: URLRequest) async throws -> Item? {
    try await self.fetch(from: urlRequest.url)
  }

  func fetch(from url: URL?) async throws -> Item? {
    guard let url else { return nil }

    if let cachedRequest = await taskCache.previousRequest(for: url) {
      // A task has either been complete or is in progress
      switch cachedRequest {
        case .downloaded(let item): return item
        case .inProgress(let task): return try await task.value
      }
    }

    // Register a new task
    let task = Task {
      try await Self.downloadItem(from: url)
    }
    await taskCache.cache(inProgress: task, at: url)

    do {
      let item = try await task.value
      await taskCache.cache(downloaded: item, at: url)
      return item
    } catch {
      await taskCache.clear(cacheAt: url)
      throw error
    }
  }

  func prefetch(itemsFrom urls: [URL]) throws {
    Task.detached {
      await withTaskGroup(of: Item?.self, body: { [weak self] taskGroup in
        let weakSelf = self
        urls.forEach { [weakSelf] url in
          taskGroup.addTask {
            try? await weakSelf?.fetch(from: url)
          }
        }
      })
    }
  }

  static func downloadItem(from url: URL) async throws -> Item {
    try await Self.downloadItem(for: URLRequest(url: url))
  }

  static func downloadItem(for urlRequest: URLRequest) async throws -> Item {
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw NetworkServices.DownloadItemError.unsuccessfulResponse }
    guard let item = Item(data: data) else { throw NetworkServices.DownloadItemError.invalidData }
    return item
  }
}


extension NetworkServices {
  public enum DownloadItemError: Error {
    case invalidData
    case unsuccessfulResponse
  }
}

