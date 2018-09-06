//
//  Cache.swift
//  Astronomy
//
//  Created by Jeremy Taylor on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key: Hashable {
    private var cachedItems: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.lambdaschool.Astronomy.CacheQueue")
    
    subscript(_ key: Key) -> Value? {
        get {
            return queue.sync { cachedItems[key] ?? nil }
            
        }
    }
    
    func cache(value: Value, for key: Key) {
        queue.async { self.cachedItems[key] = value }
        
    }
    
    func value(for key: Key) {
        queue.sync {
            guard let index = cachedItems.index(forKey: key) else { return }
             cachedItems.remove(at: index)
        }
        
       
    }
}
