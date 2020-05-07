//
//  Cache.swift
//  Astronomy
//
//  Created by Chris Dobek on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var storage = [Key: Value]()
    
    func cache(value: Value, for key: Key){
        storage[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return storage[key] ?? nil
    }
}
