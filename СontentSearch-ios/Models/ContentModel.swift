//
//  ContentModel.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 12.04.2024.
//

import Foundation

struct ContentModelResult: Codable, Hashable {
    let resultCount: Int
    let results: [ContentModel]
}

struct ContentModel: Codable, Hashable {
    let wrapperType: String?
    let kind: String?
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let collectionCensoredName: String?
    let trackCensoredName: String?
    let artistViewUrl: String?
    let collectionViewUrl: String?
    let trackViewUrl: String?
    let previewUrl: String?
    let artworkUrl60: String?
    let artworkUrl100: String?
    let collectionExplicitness: String?
    let trackExplicitness: String?
    let country: String?
    let currency: String?
    let primaryGenreName: String?
    
    let artistId: Int?
    let collectionId: Int?
    let trackId: Int?
    let discCount: Int?
    let discNumber: Int?
    let trackCount: Int?
    let trackNumber: Int?
    let trackTimeMillis: Int?
    
    let collectionPrice: Double?
    let trackPrice: Double?
}
