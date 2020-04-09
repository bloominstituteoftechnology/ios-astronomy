//
//  Cache.swift
//  Astronomy
//
//  Created by Shawn Gee on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    // MARK: - Public
    
    func cache(_ value: Value, for key: Key) {
        store[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return store[key]
    }
    
    // MARK: - Private
    
    private var store: [Key: Value] = [:]
}
