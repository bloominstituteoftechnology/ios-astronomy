//
//  Cache.swift
//  Astronomy
//
//  Created by Nelson Gonzalez on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    var cachedImages: [Key: Value] = [:]
    
    func cache(value: Value?, for theKey: Key) {
        cachedImages[theKey] = value
    }
    
    func value(for theKey: Key) -> Value? {
       return cachedImages[theKey]
    }
}
