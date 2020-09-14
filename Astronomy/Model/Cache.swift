//
//  Cache.swift
//  Astronomy
//
//  Created by Waseem Idelbi on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var dictionary = [Key : Value]()
    
    func cache(value: Value, for key: Key) {
        dictionary[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return dictionary[key]
    }
    
    
}
