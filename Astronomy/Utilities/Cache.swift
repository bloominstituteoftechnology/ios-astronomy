//
//  Cache.swift
//  Astronomy
//
//  Created by Jon Bash on 2019-12-05.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var _cache = [Key: Value]()
    
    subscript(key: Key) -> Value? {
        get {
            return _cache[key]
        }
        set {
            _cache[key] = newValue
        }
    }
}
