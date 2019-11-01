//
//  Cache.swift
//  Astronomy
//
//  Created by macbook on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var catchedItems: [Key : Value] = [:]
    private let queue = DispatchQueue(label: "MyQueue")
    
    
    func cache(value: Value, key: Key) {
        queue.async {
            self.catchedItems[key] = value
        }
    }
    
    func value(key: Key) -> Value? {
        return queue.sync {
            catchedItems[key]        }
    }
    
    
    
}
