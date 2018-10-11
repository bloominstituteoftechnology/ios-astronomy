//
//  Cache.swift
//  Astronomy
//
//  Created by Ilgar Ilyasov on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache <Key: Hashable, Value> {
    
    let queue = DispatchQueue(label: "com.ilqarilyasov.astronomyApp.searialCacheQueue")
    private var cacheItems: [Key: Value] = [:]
    
    // Add new pair
    func cache(value: Value, forKey: Key) {
        queue.async { self.cacheItems[forKey] = value }
    }
    
    // Return the value
    func value(forKey: Key) -> Value? {
        return queue.sync { self.cacheItems[forKey] }
    }
    
}
