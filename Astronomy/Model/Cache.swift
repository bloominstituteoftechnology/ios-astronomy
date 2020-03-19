//
//  Cache.swift
//  Astronomy
//
//  Created by David Wright on 3/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    // MARK: - Properties

    private var dictionary: [Key : Value] = [:]
    
    // MARK: - Methods
    
    func cache(value: Value, for key: Key) {
        dictionary[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return dictionary[key]
    }
}
