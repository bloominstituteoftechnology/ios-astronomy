//
//  Cache.swift
//  Astronomy
//
//  Created by Ivan Caldwell on 1/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


// Create a new file called Cache.swift .
// Create a class called Cache . It should be generic with respect
// to the type it stores, and its keys. e.g. Cache<Key,Value>.
// The generic Key type will need to be constrained to conform to Hashable.
class Cache<Key, Value> where Key: Hashable {
    // Create a private property that is a dictionary to be used to actually
    // store the cached items. The type of the dictionary should be
    // [Key : Value]. Make sure you initialize it with an empty dictionary.
    private var cacheDictionary: [Key:Value] = [:]
    private let queue = DispatchQueue(label: "cacheQueue")
    // Implement cache(value:, for:) and value(for:) methods to add
    // items to the cache and remove them, respectively
    func cache(forKey key: Key , forValue value: Value ) {
        queue.sync() {
            cacheDictionary[key] = value
        }
    }
    
    
    func value(for key: Key) -> Value?{
        return queue.sync { cacheDictionary[key] }
    }
}
