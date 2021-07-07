//
//  Cache.swift
//  Astronomy
//
//  Created by Rick Wolter on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


class Cache <Key: Hashable, Value> {
    
    // A place for items to be cached
    private var cache = [Key: Value]()
    
    // Serial queue so everyone can use shared resources without using NSLock
    private var queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")
    
    
    // have a function to add items to the cache
    func cache(key: Key, value: Value){
        queue.async {
            self.cache[key] = value
        }
    }
    
    // have a function to return items that are cache
    
    func value(key: Key) -> Value? {
        return queue.sync {
            cache[key]
        }
    }
    
    
}
