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
    private var queue = DispatchQueue(label: "com.Stefano.Astronomy.Cache")
    
    func cache(value: Value, for key: Key) {
        queue.sync {
            store[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        var value: Value?
        
        queue.sync {
            for cache in store {
                if cache.key == key {
                    value = cache.value
                }
            }
        }
        
        if let value = value { return value } else { return nil }
    }
    
}
