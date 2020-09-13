//
//  Cache.swift
//  Astronomy
//
//  Created by ronald huston jr on 9/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    //  set up the cache
    private var cache = [Key : Value]()
    
    //  create a serial queue
    private var queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")
    
    //  add items to the cache of type dictionary
    func cache(key: Key, value: Value) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    //  return items from the cache of type dictionary
    func value(key: Key) -> Value? {
        //  decision to run sync
        return queue.sync {
            cache[key]
        }
    }
}
