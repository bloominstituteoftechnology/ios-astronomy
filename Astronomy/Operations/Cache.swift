//
//  Cache.swift
//  Astronomy
//
//  Created by Jake Connerly on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<T: Hashable, Value> {
    
    private(set) var cachedItems: [T: Value] = [:]
    
    func cache(value: Value, for key: T) {
        cachedItems[key] = value
    }
    
    func value(for key: T) -> Value? {
        guard let value = cachedItems[key] else { return nil }
        return value
    }
}

