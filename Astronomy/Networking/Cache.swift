//
//  Cache.swift
//  Astronomy
//
//  Created by Hunter Oppel on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cache = [Key: Value]()
    
    private let cacheQueue = DispatchQueue(label: "com.LambdaSchool.Astronomy.cacheQueue<\(Key.self), \(Value.self)")
    
    func cache(_ value: Value?, for key: Key) {
        cacheQueue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        cacheQueue.sync {
            return cache[key]
        }
    }
    
    subscript(key: Key) -> Value? {
        get {
            value(for: key)
        }
        set(newValue) {
            cache(newValue, for: key)
        }
    }
}
