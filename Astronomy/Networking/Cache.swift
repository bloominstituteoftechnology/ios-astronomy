//
//  Cache.swift
//  Astronomy
//
//  Created by Jeremy Taylor on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key: Hashable {
    private var cachedItems: [Key: Value] = [:]
    
    subscript(_ key: Key) -> Value? {
        get {
            return cachedItems[key] ?? nil
        }
    }
    
    func cache(value: Value, for key: Key) {
         cachedItems[key] = value
    }
    
    func value(for key: Key) {
        guard let index = cachedItems.index(forKey: key) else { return }
        cachedItems.remove(at: index)
    }
}
