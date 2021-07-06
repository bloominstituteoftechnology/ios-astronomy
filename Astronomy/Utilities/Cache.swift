//
//  Cache.swift
//  Astronomy
//
//  Created by John Kouris on 11/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key,Value> where Key: Hashable {
    
    private var cachedDictionary: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "RoverPhotoCacheQueue")
    
    func addToCache(value: Value, for key: Key) {
        queue.async {
            self.cachedDictionary[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            guard let value = cachedDictionary[key] else { return nil }
            return value
        }
    }
    
}
