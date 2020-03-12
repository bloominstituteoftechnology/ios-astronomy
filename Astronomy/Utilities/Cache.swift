//
//  Cache.swift
//  Astronomy
//
//  Created by scott harris on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private(set) var dictionary: [Key: Value] = [:]
    private var queue = DispatchQueue(label: "Astronomy.Image.Cache")
    
    func cache(value: Value, for key: Key) {
        dictionary[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return dictionary[key]
    }
    
}
