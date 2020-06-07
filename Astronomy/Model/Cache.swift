//
//  Cache.swift
//  Astronomy
//
//  Created by Nonye on 6/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable , Value> {
    
    // a place for items to be cached
    private var cache = [Key : Value]()
    // serial queue so everyone can use shared resources without NSLock
    private var queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")
    // function for adding items to cache
    
    func cache(value: Value, key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    // a function to return item that are cache
    func value(key: Key) -> Value? {
        return queue.sync {
            cache[key]
        }
    }
}
