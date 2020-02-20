//
//  Cache.swift
//  Astronomy
//
//  Created by Jorge Alvarez on 2/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

// Avoid doing network requests for images that are already in Cache
class Cache<Key: Hashable, Value> {
    
    /// Stores cached items, initialized with an empty dictionary
    private var dictionary: [Key : Value] = [ : ]
     
    private let queue = DispatchQueue(label: "Serial Queue")
    
    /// Adds items to cache (setting of value occurs on the queue)
    func cache(value: Value, for key: Key) {
        queue.async {
            self.dictionary[key] = value
        }
    }
    
    /// Returns associated value from cache
    func value(for key: Key) -> Value? {
        queue.sync {
            return dictionary[key]
        }
    }
}
