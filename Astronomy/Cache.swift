//
//  Cache.swift
//  Astronomy
//
//  Created by Kelson Hartle on 6/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cached = [Key: Value]()

    
    //MARK: - Editing the set
    func cache(value: Value, for key: Key) {
        cached[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cached[key]
    }
}
