//
//  Cache.swift
//  Astronomy
//
//  Created by Matthew Martindale on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var cacheDictionary: [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cacheDictionary[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cacheDictionary[key]
    }
}
