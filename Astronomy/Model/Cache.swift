//
//  Cache.swift
//  Astronomy
//
//  Created by Seschwan on 8/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable,Value> {
    private var cacheDictionary:  [Key : Value] = [:]
    private let q = DispatchQueue(label: "PrivateDispatchQ")
    
    
    
    func cache(value: Value, key: Key) {
        q.async {
            self.cacheDictionary[key] = value
        }
    }
    
    func value(key: Key) -> Value? {
        return q.sync {
            cacheDictionary[key]
        }
    }
}
