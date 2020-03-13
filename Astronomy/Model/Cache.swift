//
//  Cache.swift
//  Astronomy
//
//  Created by Tobi Kuyoro on 12/03/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private let queue = DispatchQueue(label: "CacheQueue")
    private var cache: [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            return self.cache[key]
        }
    }
}
