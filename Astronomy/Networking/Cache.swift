//
//  Cache.swift
//  Astronomy
//
//  Created by Hunter Oppel on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cachedItems = [Key: Value]()
    
    func cache(value: Value, for key: Key) {
        cachedItems[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cachedItems[key]
    }
}
