//
//  SolDescription.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 BloomTech. All rights reserved.
//

import Foundation

struct SolDescription: Codable {
    let sol: Int
    let totalPhotos: Int
    let cameras: [String]
}
