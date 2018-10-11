//
//  Cache.swift
//  Astronomy
//
//  Created by Ilgar Ilyasov on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache <Key: Hashable, Value> {
    
    private var cacheItems: [Key: Value] = [:]
    
    // Add new pair
    func cache(value: Value, forKey: Key) {
        cacheItems[forKey] = value
    }
    
    // Remove a pair
    func value(forKey: Key) -> Value? {
        return cacheItems[forKey]
    }
    
}
