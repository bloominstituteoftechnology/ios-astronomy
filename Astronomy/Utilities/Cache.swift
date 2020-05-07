//
//  Cache.swift
//  Astronomy
//
//  Created by Bhawnish Kumar on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var cacheQueue = DispatchQueue(label: "MyCacheSerialQueue")
    
    private var dict: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cacheQueue.async {
            
            self.dict[key] = value
        }
    }
    func value(for key: Key) -> Value? {
        cacheQueue.sync {
            self.dict[key]
        }
    }
}
