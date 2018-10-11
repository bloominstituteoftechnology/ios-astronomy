//
//  Cache.swift
//  Astronomy
//
//  Created by Dillon McElhinney on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cachedItems: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cachedItems[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cachedItems[key]
    }
}
