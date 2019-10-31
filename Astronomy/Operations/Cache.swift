//
//  Cache.swift
//  Astronomy
//
//  Created by Jesse Ruiz on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private let queue = DispatchQueue(label: "MyCacheQueue")
    private var cacheDictionary: [Key : Value] = [:]
    
    func addToCache(value: Value, for key: Key) {
        queue.async {
            self.cacheDictionary[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            guard let value = cacheDictionary[key] else { return nil }
            return value
        }
    }
}
