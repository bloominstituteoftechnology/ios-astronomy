//
//  Cache.swift
//  Astronomy
//
//  Created by Moses Robinson on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class Cache<Key: Hashable, Value> {
    
    func cache(value: Value, for key: Key) {
        cachedItems[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cachedItems[key]
    }
    
    private var cachedItems: [Key : Value] = [:]
}
