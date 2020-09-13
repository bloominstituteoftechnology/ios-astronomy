//
//  Cache.swift
//  Astronomy
//
//  Created by ronald huston jr on 9/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    //  Key is constrained to conform to Hashable
    //  set up the cache, an empty dictionary
    private var cache = [Key : Value]()
    
    //  create a serial queue
    private var queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")
    
    //  add items to the cache of type dictionary
    func cache(key: Key, value: Value) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    //  to return associated value from the cache
    func value(key: Key) -> Value? {
        //  use a synchronous dispatch to retrieve the requested value
        return queue.sync {
            cache[key]
        }
    }
}
