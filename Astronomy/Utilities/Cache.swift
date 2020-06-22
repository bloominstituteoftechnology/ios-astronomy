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
    private var q: DispatchQueue
    
    init(name: String? = nil) {
        self.q = DispatchQueue(label: name ?? "Cache<\(Key.self), \(Value.self)>")
    }
    
    subscript(key: Key) -> Value? {
        get { q.sync { return _cache[key] } }
        set { q.sync { _cache[key] = newValue } }
    }
}
