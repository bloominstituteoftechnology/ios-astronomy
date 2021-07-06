//
//  Cache.swift
//  Astronomy
//
//  Created by Kevin Stewart on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var dictionary: [Key : Value] = [:]
    private var cacheQueue = DispatchQueue(label: "MyCacheQueue")
    
    func cache(value: Value, for key: Key) {
        cacheQueue.async {
            self.dictionary[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        cacheQueue.sync {
            self.dictionary[key]
        }
    }
    
}
