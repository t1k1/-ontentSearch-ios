//
//  TimeConverter.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 14.04.2024.
//

import Foundation

final class TimeConverter {
    static func convertMillis(_ trackTimeMillis: Int, contentKind: String?) -> String {
        var result = ""
        
        let totalSeconds = Double(trackTimeMillis) / 1000
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if contentKind == "MOVIE" {
            result = "\(hours) h. \(minutes) min."
        } else if contentKind == "PODCAST" {
            if hours > 0 {
                result = "\(hours) h. \(minutes) min."
            } else if minutes > 0 {
                result = "\(hours) h. \(minutes) min."
            }
        } else if contentKind == "SONG" {
            result = "\(minutes) min. \(seconds) sec."
        }
        
        return result
    }
}
