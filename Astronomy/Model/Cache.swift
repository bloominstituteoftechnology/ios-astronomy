//
//  Cache.swift
//  Astronomy
//
//  Created by brian vilchez on 10/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
class Cache<Key: Hashable, Value> {
    private var cache = [Key: Value]()
    private var queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")
    
    func cache(value value: Value, forKey key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func getValue(forKey key: Key) -> Value? {
        return queue.sync {
            self.cache[key]
        }
    }
}
