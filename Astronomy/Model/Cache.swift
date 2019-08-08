//
//  Cache.swift
//  Astronomy
//
//  Created by Kat Milton on 8/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    private var cachedItems: [Key : Value]  = [:]
    
    private let queue = DispatchQueue(label: "AstronomyCache")
  
    func cache(value: Value, key: Key){
        queue.async {
            self.cachedItems[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync {
            cachedItems[key]
        }
    }
}
