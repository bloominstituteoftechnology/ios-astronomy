//
//  MarsRover.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 BloomTech. All rights reserved.
//

import Foundation

struct MarsRover: Codable {
    let name: String
    
    let launchDate: Date
    let landingDate: Date
    
    enum Status: String, Codable {
        case active, complete
    }
    let status: Status
    
    let maxSol: Int
    let maxDate: Date
    
    let numberOfPhotos: Int
    
    let solDescriptions: [SolDescription]
    
    enum CodingKeys: String, CodingKey {
        case name
        case launchDate
        case landingDate
        case status
        case maxSol
        case maxDate
        case numberOfPhotos = "totalPhotos"
        case solDescriptions = "photos"
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static var jsonDecoder: JSONDecoder {
        let result = JSONDecoder()
        result.keyDecodingStrategy = .convertFromSnakeCase
        result.dateDecodingStrategy = .formatted(dateFormatter)
        return result
    }
}
