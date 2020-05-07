//
//  Cache.swift
//  Astronomy
//
//  Created by Mark Poggi on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    // set up the cache
    private var cache = [Key : Value]()

    // created a serial queue
    private var queue = DispatchQueue(label: "placeholder")

    // add items to the cache of type dictionary
    func cache(value: Value, key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }

    // return items from the cache of type dictionary
    func value(key: Key) -> Value? {
        // Making this sync rather than async.  Needs to work with other threads.
        return queue.sync {
            cache[key]
        }
    }



}
