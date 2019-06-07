//
//  Cache.swift
//  Astronomy
//
//  Created by Christopher Aronson on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cache: [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cache.updateValue(value, forKey: key)
    }
    
    func value(for key: Key) -> Value? {
        guard let value = cache[key] else { return nil }
        
        return value
    }
}
