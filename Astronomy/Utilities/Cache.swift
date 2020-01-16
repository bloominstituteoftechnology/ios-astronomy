//
//  Cache.swift
//  Astronomy
//
//  Created by Chad Rutherford on 1/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var dict = [Key : Value]()
    private let queue = DispatchQueue(label: "CacheQueue")
    
    func cache(value: Value, for key: Key) {
        queue.sync {
            self.dict[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            return dict[key]
        }
    }
    
    func contains(_ key: Key) -> Bool {
        return queue.sync {
            dict.keys.contains(key)
        }
    }
}
