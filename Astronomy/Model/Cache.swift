//
//  Cache.swift
//  Astronomy
//
//  Created by Enrique Gongora on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var storage = [Key: Value]()
    
    func cache(value: Value, for key: Key) {
        storage[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return storage[key] ?? nil
    }
}
