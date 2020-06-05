//
//  Cache.swift
//  Astronomy
//
//  Created by Harmony Radley on 6/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    private var cache = [Key : Value]()

    private var queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")

    // add items to the dictionary(cache)
    func cache(key: Key, value: Value) {
        queue.async {
            self.cache[key] = value
        }
    }

    // return items from the dictionary(cache)
    func value(key: Key) -> Value? {
         queue.sync {
            self.cache[key]
        }
    }
}
