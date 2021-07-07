//
//  Cache.swift
//  Astronomy
//
//  Created by Chris Gonzales on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


class Cache<Key, Value> where Key: Hashable {
    
    private var cacheDictionary: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.Astronomy.cacheQueue")
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cacheDictionary[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            guard let value = cacheDictionary[key] else { return nil }
            return value
        }
    }
}
