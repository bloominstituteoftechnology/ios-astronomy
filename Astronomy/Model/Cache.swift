//
//  Cache.swift
//  Astronomy
//
//  Created by Kobe McKee on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


class Cache<Key: Hashable, Value> {
    
    private var cache: [Key : Value] = [:]
    private let queue = DispatchQueue(label: "AstronomyCacheQueue")
    
    func cache(value: Value, key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func value(key: Key) -> Value? {
        return queue.sync { cache[key] }
    }
    
}
