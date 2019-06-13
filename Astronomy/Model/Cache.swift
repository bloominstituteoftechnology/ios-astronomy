//
//  Cache.swift
//  Astronomy
//
//  Created by Mitchell Budge on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    var cacheStorage = [Key : Value]()
    let dispatchQueue = DispatchQueue(label: "com.LambdaSchool.Astronomy.CacheQueue")
    
    func cache(value: Value, for key: Key) {
        dispatchQueue.async {
            self.cacheStorage[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return dispatchQueue.sync { cacheStorage[key] }
    }
    
    
}
