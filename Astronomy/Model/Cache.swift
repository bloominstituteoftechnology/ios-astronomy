//
//  Cache.swift
//  Astronomy
//
//  Created by De MicheliStefano on 06.09.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key: Hashable {
    
    private var store: [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        store[key] = value
    }
    
    func value(for key: Key) -> Value? {
        for cache in store {
            if cache.key == key {
                return cache.value
            }
        }
        return nil
    }
    
}
