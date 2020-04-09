//
//  Cache.swift
//  Astronomy
//
//  Created by Tobi Kuyoro on 09/04/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private let memory: [Key: Value] = [:]
    
    func cache(value: Value, for: Key) {
        
    }
    
    func value(for key: Key) -> Value? {
        return memory[key]
    }
}
