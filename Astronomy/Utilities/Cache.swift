//
//  Cache.swift
//  Astronomy
//
//  Created by Michael Stoffer on 7/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cachedItems: [Key : Value] = [:]
    private let queue = DispatchQueue(label: "MySerialQueue")
    
    func cache(value: Value, key: Key) {
        queue.sync {
            self.cachedItems[key] = value
        }
    }
    
    func value(key: Key) -> Value? {
        return queue.sync {
            self.cachedItems[key]
        }
    }
}
