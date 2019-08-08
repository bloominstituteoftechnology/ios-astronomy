//
//  Cache.swift
//  Astronomy
//
//  Created by Sean Acres on 8/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cachedItems: [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cachedItems.updateValue(value, forKey: key)
    }
    
    func value(for key: Key) -> Value? {
        return cachedItems[key]
    }
}
