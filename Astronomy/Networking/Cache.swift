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
    
    func cache(value: Value, for key: Key) {
        self.cache[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cache[key]
    }
}
