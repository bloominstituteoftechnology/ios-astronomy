//
//  Cache.swift
//  Astronomy
//
//  Created by Joseph Rogers on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private let cacheQueue = DispatchQueue(label: "CQueue")
     private var cache: [Key : Value] = [:]
    func cache(value: Value, for key: Key) {
        cacheQueue.async {
            self.cache[key] = value
        }
    }
    func value(for key: Key) -> Value? {
        cacheQueue.sync {
            return self.cache[key]
        }
    }
}
