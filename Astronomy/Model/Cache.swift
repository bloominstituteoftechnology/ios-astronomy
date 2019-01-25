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

    // Add + Remove Update
    func cache(value: Value, for key: Key){
        items[key] = value
    }
    
    func value(for key: Key) -> Value?{
        return items[key]
    }
    
}


