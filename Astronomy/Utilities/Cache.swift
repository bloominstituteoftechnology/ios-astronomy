//
//  Cache.swift
//  Astronomy
//
//  Created by Thomas Dye on 5/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

import Foundation

class Cache<Key: Hashable, Value> {
    private var cacheDictionary: [Key : Value] = [:]

    private var queue = DispatchQueue.init(label: "image.cache.queue")
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cacheDictionary[key] = value
        }
        
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync {
            cacheDictionary[key]
        }
    }
}
