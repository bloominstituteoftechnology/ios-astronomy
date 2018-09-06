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
        queue.async {
            self.cachedItems[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync {
            return cachedItems[key]
        }
    }
    
    private var cachedItems: [Key : Value] = [:]
    private let queue = DispatchQueue(label: "com.LisaSampson.ThreadSafeSerialQueue")
    
}
