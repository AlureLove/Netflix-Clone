//
//  APICaller.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/11/16.
//

import Foundation

enum Constants {
    static let baseURL = "https://api.themoviedb.org/3"
    static let bearerToken = APIKeys.tmdbBearerToken
}

enum APIError: Error {
    case invalidURL
    case failedToGetData
    case invalidResponse
    case decodingError
}

final class APICaller {
    static let shared = APICaller()

    private init() {}
    
    // MARK: - Private Helper Methods
    
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(Constants.bearerToken)"
        ]
        return request
    }
    
    private func fetchData<T: Codable>(from url: URL) async throws -> T {
        let request = createRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: - Public API Methods
    
    func getTrendingMovies() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/trending/movie/day") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "language", value: "en-US")
        ]
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        let response: TrendingTitleResponse = try await fetchData(from: finalURL)
        return response.results
    }
    
    func getTrendingTVs() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/trending/tv/day") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "language", value: "en-US")
        ]
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        let response: TrendingTitleResponse = try await fetchData(from: finalURL)
        return response.results
    }
    
    func getUpcomingMovies() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/movie/upcoming") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        let response: TrendingTitleResponse = try await fetchData(from: finalURL)
        return response.results
    }
    
    func getPopularMovies() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/movie/popular") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        let response: TrendingTitleResponse = try await fetchData(from: finalURL)
        return response.results
    }
    
    func getTopRatedMovies() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/movie/top_rated") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        let response: TrendingTitleResponse = try await fetchData(from: finalURL)
        return response.results
    }
    
    func getDiscoverMovies() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/discover/movie") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        let response: TrendingTitleResponse = try await fetchData(from: finalURL)
        return response.results
    }
    
    func search(with query: String) async throws -> [Title] {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { throw APIError.decodingError }
        
        guard let url = URL(string: "\(Constants.baseURL)/search/movie?query=\(query)") else { throw APIError.invalidURL }
        
        let response: TrendingTitleResponse = try await fetchData(from: url)
        return response.results
    }
}
