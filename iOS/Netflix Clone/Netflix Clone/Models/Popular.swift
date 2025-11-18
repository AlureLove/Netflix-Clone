//
//  Popular.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/11/18.
//

import Foundation

struct PopularMoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
