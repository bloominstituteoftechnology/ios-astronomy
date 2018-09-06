//
//  Cache.swift
//  Astronomy
//
//  Created by Linh Bouniol on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class Cache<Key, Value> where Key: Hashable {
    
    // Dictionary that stores cached items
    private var cachedItems: [Key : Value] = [:]
    
    // This is necessary for when you have a generic class/struct, and you want to be able to use something[key or index] syntax
    subscript(_ key: Key) -> Value? {
        return value(for: key)
    }
    
    func cache(value: Value, for key: Key) {
        // Add items to cache
        cachedItems[key] = value
    }
    
    func value(for key: Key) -> Value? {
//        // Get index of the cached item
//        guard let index = cachedItems.index(forKey: key) else { return }
//        cachedItems.remove(at: index)
        
        return cachedItems[key]
    }
}
