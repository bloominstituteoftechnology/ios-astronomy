//
//  Cache.swift
//  Astronomy
//
//  Created by Vici Shaweddy on 11/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key:Hashable {
    private var cache: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "Cache")
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            return cache[key]
        }
    }
}
