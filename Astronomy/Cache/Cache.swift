//
//  Cache.swift
//  Astronomy
//
//  Created by Elizabeth Wingate on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key,Value> where Key: Hashable {

    private var cachedDictionary: [Key: Value] = [:]
    
}
