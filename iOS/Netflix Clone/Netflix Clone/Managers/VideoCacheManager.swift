//
//  VideoCacheManager.swift
//  Netflix Clone
//
//  Created by Claude on 2025/11/27.
//

import Foundation
import UIKit

class VideoCacheManager {
    static let shared = VideoCacheManager()

    private let cache = NSCache<NSString, NSString>()
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    private var cacheTimestamps: [String: Date] = [:]

    private init() {
        // Configure cache
        cache.countLimit = 100 // Maximum 100 cached URLs
        cache.totalCostLimit = 1024 * 1024 // 1MB (for metadata)

        // Setup memory warning observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    /// Get cached video URL for a movie title
    func getCachedVideoURL(for title: String) -> String? {
        let key = cacheKey(for: title)

        // Check if cache exists and is not expired
        if let timestamp = cacheTimestamps[key],
           Date().timeIntervalSince(timestamp) < cacheExpirationTime,
           let cachedURL = cache.object(forKey: key as NSString) {
            return cachedURL as String
        }

        // Cache expired or doesn't exist
        if cacheTimestamps[key] != nil {
            removeCache(for: title)
        }

        return nil
    }

    /// Cache video URL for a movie title
    func cacheVideoURL(_ url: String, for title: String) {
        let key = cacheKey(for: title)
        cache.setObject(url as NSString, forKey: key as NSString)
        cacheTimestamps[key] = Date()
    }

    /// Remove cached video URL for a specific title
    func removeCache(for title: String) {
        let key = cacheKey(for: title)
        cache.removeObject(forKey: key as NSString)
        cacheTimestamps.removeValue(forKey: key)
    }

    /// Clear all cached video URLs
    @objc func clearCache() {
        cache.removeAllObjects()
        cacheTimestamps.removeAll()
    }

    // MARK: - Private Methods

    private func cacheKey(for title: String) -> String {
        // Normalize the title to create a consistent cache key
        return title.lowercased().trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Cache Statistics (for debugging)

    func getCacheStatistics() -> (count: Int, oldestEntry: Date?) {
        let count = cacheTimestamps.count
        let oldestEntry = cacheTimestamps.values.min()
        return (count, oldestEntry)
    }
}
