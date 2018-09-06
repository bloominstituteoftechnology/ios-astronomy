//
//  Cache.swift
//  Astronomy
//
//  Created by Conner on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    func cache(value: Value, for key: Key) {
        cachedItems[key] = value
    }
    
    func value(for key: Key) {
        cachedItems[key] = nil
    }
    
    internal var cachedItems: [Key : Value] = [:]
}
