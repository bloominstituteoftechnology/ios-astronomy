//
//  Cache.swift
//  Astronomy
//
//  Created by Stephanie Ballard on 6/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class Cache<Key: Hashable, Value> {
    
    private var cache = [Key : Value]()
    private let queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.CacheQueue")
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync {
            cache[key]
        }
    }
}
