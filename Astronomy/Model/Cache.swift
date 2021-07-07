//
//  Cache.swift
//  Astronomy
//
//  Created by Dillon P on 11/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var cache: [Key: Value] = [:]
    private let cacheQueue = DispatchQueue(label: "Cache Queue")
    
    func cache(value: Value, for key: Key) {
        cacheQueue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        cacheQueue.sync {
            return self.cache[key]
        }
    }
    
}
