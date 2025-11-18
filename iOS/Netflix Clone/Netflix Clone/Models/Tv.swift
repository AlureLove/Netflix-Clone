//
//  Tv.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/11/18.
//

import Foundation

struct TrendingTVsResponse: Codable {
    let page: Int
    let results: [TV]
}

struct TV: Codable {
    let adult: Bool
    let backdropPath: String?
    let id: Int
    let name: String
    let originalName: String
    let overview: String
    let posterPath: String?
    let mediaType: String
    let originalLanguage: String
    let genreIds: [Int]
    let popularity: Double
    let firstAirDate: String?
    let voteAverage: Double
    let voteCount: Int
    let originCountry: [String]
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case id
        case name
        case originalName = "original_name"
        case overview
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
        case popularity
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originCountry = "origin_country"
    }
}
