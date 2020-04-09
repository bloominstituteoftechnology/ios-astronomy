//
//  Cache.swift
//  Astronomy
//
//  Created by Lambda_School_Loaner_259 on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value>  {
    private var cachedItems: [Key : Value] = [:]
    private var queue = DispatchQueue(label: "Cache Queue")
    
    func cache(value: Value, forKey: Key) {
        queue.async {
            self.cachedItems[forKey] = value
        }
        
    }
    
    func value(forKey: Key) -> Value? {
        queue.sync {
            return cachedItems[forKey]
        }
    }
}
