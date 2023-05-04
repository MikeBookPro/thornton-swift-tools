import Foundation

/// Code based off example from WWDC '21 Video [Protect mutable state with Swift actors](https://developer.apple.com/wwdc21/10133)
extension NetworkServices {
    public actor TaskCache<Item> {
        public enum CacheEntry {
            case inProgress(Task<Item, Error>)
            case downloaded(Item)
        }
        
        private var cache: [URL: CacheEntry] = [:]
        
        public init(cache: [URL: CacheEntry] = [:]) {
            self.cache = cache
        }
        
        /// Provides a CacheEntry associated with the provided URL, if one exists
        public func previousRequest(for url: URL) async -> CacheEntry? { cache[url] }
        
        /// Caches the provided task as `inProgress`
        public func cache(inProgress task: Task<Item, Error>, at url: URL) {
            cache[url] = .inProgress(task)
        }
        
        /// Caches the provided item as `downloaded`
        public func cache(downloaded item: Item, at url: URL) {
            cache[url] = .downloaded(item)
        }
        
        /// Resets the cache for the provided URL
        public func clear(cacheAt url: URL) {
            cache[url] = nil
        }
    }
}

