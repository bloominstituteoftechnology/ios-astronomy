//
//  Cache.swift
//  Astronomy
//
//  Created by Bradley Yin on 9/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var dictionary : [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        dictionary[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return dictionary[key]
    }
}
