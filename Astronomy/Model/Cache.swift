//
//  Cache.swift
//  Astronomy
//
//  Created by Bobby Keffury on 11/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    func cache(value: Value, for key: Key) {
        cache[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cache[key]
    }
    
    private var cache = [Key : Value]()
}

