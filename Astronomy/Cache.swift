//
//  Cache.swift
//  Astronomy
//
//  Created by Fabiola S on 11/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cache: [Key : Value] = [:]
    private var queue = DispatchQueue(label: "SerialQueue")
    
    func cache(value: Value, key: Key) {
        queue.sync {
            self.cache[key] = value
        }
    }
    
    func value(key: Key) -> Value? {
        return queue.sync {
            self.cache[key]
        }
    }
    
}
