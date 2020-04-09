//
//  Cache.swift
//  Astronomy
//
//  Created by Karen Rodriguez on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cache: [Key : Value] = [ : ]
    
    func cache(value: Value, for key: Key) {
        cache[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cache[key]
    }
}
