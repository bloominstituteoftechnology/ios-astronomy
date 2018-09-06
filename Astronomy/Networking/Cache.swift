//
//  Cache.swift
//  Astronomy
//
//  Created by Lisa Sampson on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key: Hashable {
    
    func cache(value: Value, for key: Key) {
        cachedItems[key] = value
    }
    
    func value(for key: Key) {
        guard let index = cachedItems.index(forKey: key) else { return }
        cachedItems.remove(at: index)
    }
    
    subscript(_ key: Key) -> Value? {
        return cachedItems[key] ?? nil
    }
    
    private var cachedItems: [Key : Value] = [:]
    
}
