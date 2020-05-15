//
//  Cache.swift
//  Astronomy
//
//  Created by Breena Greek on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache <Key: Hashable, Value> {
    
    private var cachePhotoDictionary: [Key: Value] = [:]
    
    func cache(value: Value , for key: Key) {
        cachePhotoDictionary[key] = value
    }
    
    func value(for key: Key ) -> Value? {
        return cachePhotoDictionary[key]
    }
    
}
