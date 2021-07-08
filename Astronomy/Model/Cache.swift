//
//  Cache.swift
//  Astronomy
//
//  Created by Benjamin Hakes on 1/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var items: [Key: Value] = [:]
    private var queue = DispatchQueue(label: "threadSafeCacheQueue")
    
    // Add + Remove Update
    func cache(value: Value, for key: Key){
        queue.async { self.items[key] = value }
    }
    
    func value(for key: Key) -> Value?{
        return queue.sync { items[key] }
    }
    
}


