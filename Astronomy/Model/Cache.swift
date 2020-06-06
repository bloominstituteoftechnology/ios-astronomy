//
//  Cache.swift
//  Astronomy
//
//  Created by Stephanie Ballard on 6/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class Cache<Key: Hashable, Value> {
    
    // a place for items to be cached
    private var cache = [Key : Value]()
    
    // serial queue so that everyone can use shared resources without using nslock
    private let queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.CacheQueue")
    
    // have a function to add items to the cache
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    // have a function to return items that are cache, optional in case it doesn't exist
    func value(for key: Key) -> Value? {
        return queue.sync {
            cache[key]
        }
    }
}
