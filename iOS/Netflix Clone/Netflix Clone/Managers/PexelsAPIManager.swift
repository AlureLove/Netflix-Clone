//
//  PexelsAPIManager.swift
//  Netflix Clone
//
//  Created by Jethro on 2025/11/27.
//

import Foundation

enum PexelsAPIError: Error {
    case invalidURL
    case noAPIKey
    case requestFailed
    case invalidResponse
    case decodingError
}

final class PexelsAPIManager {
    static let shared = PexelsAPIManager()

    private let baseURL = "https://api.pexels.com/videos"
    private var apiKey: String {
        return APIKeys.pexelsAPIKey
    }

    private init() {}

    // MARK: - Search Videos
    func searchVideos(query: String, page: Int = 1, perPage: Int = 15) async throws -> PexelsVideoResponse {
        guard !apiKey.isEmpty else {
            throw PexelsAPIError.noAPIKey
        }

        var components = URLComponents(string: "\(baseURL)/search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = components?.url else {
            throw PexelsAPIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    // MARK: - Get Popular Videos
    func getPopularVideos(page: Int = 1, perPage: Int = 15) async throws -> PexelsVideoResponse {
        guard !apiKey.isEmpty else {
            throw PexelsAPIError.noAPIKey
        }

        var components = URLComponents(string: "\(baseURL)/popular")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = components?.url else {
            throw PexelsAPIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    // MARK: - Get Video by ID
    func getVideo(id: Int) async throws -> PexelsVideo {
        guard !apiKey.isEmpty else {
            throw PexelsAPIError.noAPIKey
        }

        guard let url = URL(string: "\(baseURL)/videos/\(id)") else {
            throw PexelsAPIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    // MARK: - Private Helper
    private func performRequest<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PexelsAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw PexelsAPIError.requestFailed
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw PexelsAPIError.decodingError
        }
    }

    // MARK: - Helper to get best quality video URL
    func getBestQualityVideoURL(from video: PexelsVideo) -> String? {
        // Try to find HD quality first
        if let hdVideo = video.videoFiles.first(where: { $0.quality == "hd" }) {
            return hdVideo.link
        }

        // Fall back to SD quality
        if let sdVideo = video.videoFiles.first(where: { $0.quality == "sd" }) {
            return sdVideo.link
        }

        // Return first available video
        return video.videoFiles.first?.link
    }
}
