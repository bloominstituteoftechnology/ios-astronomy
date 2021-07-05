//
//  Cache.swift
//  Astronomy
//
//  Created by morse on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable , Value> {
    private var cachedItems: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "Astronomy")
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cachedItems[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        
        queue.sync {
            if let item = cachedItems[key] {
                return item
            } else {
                return nil
            }
        }
    }
    
    
    
    
    
}
