//
//  Cache.swift
//  Astronomy
//
//  Created by denis cedeno on 3/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
/// Create a class called Cache. It should be generic with respect to the type it stores, and its keys. e.g. Cache<Key, Value>.
/// The generic Key type will need to be constrained to conform to Hashable.
class Cache<Key: Hashable, Value> {
/// Create a private property that is a dictionary to be used to actually store the cached items. The type of the dictionary should be [Key : Value]. Make sure you initialize it with an empty dictionary.
    private var cacheDictionary: [Key : Value] = [:]
///    Create a private queue property and initialize it with a serial DispatchQueue. Give it an appropriate label.
    private var queue = DispatchQueue.init(label: "image.cache.queue")
///    Implement cache(value:, for:) to add items to the cache and value(for:) to return the associated value from the cache.
    func cache(value: Value, for key: Key) {
///        In cache(value:, for:), dispatch the actual setting of the dictionary key/value pair so that it occurs on the queue.
        queue.async {
            self.cacheDictionary[key] = value
        }
        
    }
    
    func value(for key: Key) -> Value? {
///        In value(for:), use a synchronous dispatch to retrieve the requested value from the dictionary before returning it. Note that DispatchQueue.sync()'s closure can return a value which will subsequently be returned from DispatchQueue.sync() itself. This means you don't need to create a temporary variable outside the dispatched closure.
        return queue.sync {
            cacheDictionary[key]
        }
    }
}
