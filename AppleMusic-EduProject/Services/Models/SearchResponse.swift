//
//  SearchResponse.swift
//  AppleMusic-EduProject
//
//  Created by Виктор on 15.03.2021.
//

import Foundation


struct SearchResponse: Decodable {
    var resultCount: Int
    var results: [Track]
}

struct Track: Decodable {
    var trackName: String
    var collectionName: String?
    var artistName: String
    var artworkUrl100: String?
    var previewUrl: String?
}
