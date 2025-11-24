//
//  YoutubeSearchResponse.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/11/25.
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
