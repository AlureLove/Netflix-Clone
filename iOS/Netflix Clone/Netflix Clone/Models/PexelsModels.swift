//
//  PexelsModels.swift
//  Netflix Clone
//
//  Created by Jethro on 2025/11/27.
//

import Foundation

// MARK: - Pexels Video Response
struct PexelsVideoResponse: Codable {
    let page: Int
    let perPage: Int
    let totalResults: Int
    let url: String
    let videos: [PexelsVideo]

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case totalResults = "total_results"
        case url
        case videos
    }
}

// MARK: - Pexels Video
struct PexelsVideo: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let image: String
    let fullRes: String?
    let tags: [String]
    let duration: Int
    let user: PexelsUser
    let videoFiles: [PexelsVideoFile]
    let videoPictures: [PexelsVideoPicture]

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, image, tags, duration, user
        case fullRes = "full_res"
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
}

// MARK: - Pexels User
struct PexelsUser: Codable {
    let id: Int
    let name: String
    let url: String
}

// MARK: - Pexels Video File
struct PexelsVideoFile: Codable {
    let id: Int
    let quality: String
    let fileType: String
    let width: Int?
    let height: Int?
    let fps: Double?
    let link: String

    enum CodingKeys: String, CodingKey {
        case id, quality, width, height, fps, link
        case fileType = "file_type"
    }
}

// MARK: - Pexels Video Picture
struct PexelsVideoPicture: Codable {
    let id: Int
    let picture: String
    let nr: Int
}
