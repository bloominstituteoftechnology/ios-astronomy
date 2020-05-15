//
//  Cache.swift
//  Astronomy
//
//  Created by Chad Parker on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    var items: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        items[key] = value
    }
    
    func value(for key: Key) -> Value? {
        items[key]
    }
}
