//
//  Cache.swift
//  Astronomy
//
//  Created by Daniela Parra on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key: Hashable {
    
    public func cache(value: Value, for key: Key) {
        queue.async {
            self.cachedItems[key] = value
        }
    }
    
    public func value(for key: Key) -> Value? {
        return queue.sync {
            cachedItems[key]
        }
    }
    
    private var cachedItems: [Key : Value] = [:]
    private var queue = DispatchQueue(label: "com.lambdaschool.Astronomy.cacheQueue")
    
}
