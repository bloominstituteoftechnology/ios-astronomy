//
//  Cache.swift
//  Astronomy
//
//  Created by Jocelyn Stuart on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var cacheDict: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cacheDict[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cacheDict[key]
    }
    
}
