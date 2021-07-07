//
//  Cache.swift
//  Astronomy
//
//  Created by Tobi Kuyoro on 09/04/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var memory: [Key: Value] = [:]
    private let cacheQueue = DispatchQueue(label: "CacheQueue")
    
    func cache(value: Value, for key: Key) {
        cacheQueue.async {
            self.memory[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        cacheQueue.sync {
            return memory[key]
        }
    }
}
