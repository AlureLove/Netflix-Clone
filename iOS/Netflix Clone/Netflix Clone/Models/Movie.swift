//
//  Movie.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/11/16.
//

import Foundation

struct TrendingMoviesResponse: Codable {
    let page: Int
    let results: [Movie]
}

struct Movie: Codable {
    let adult: Bool
    let backdropPath: String?
    let id: Int
    let title: String?
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let mediaType: String
    let originalLanguage: String
    let genreIds: [Int]
    let popularity: Double
    let releaseDate: String?
    let video: Bool?
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case id
        case title
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
        case popularity
        case releaseDate = "release_date"
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
