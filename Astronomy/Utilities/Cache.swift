//
//  Cache.swift
//  Astronomy
//
//  Created by Wyatt Harrell on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    private var queue = DispatchQueue(label: "Cahce Queue")
    
    var dict: [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.dict[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            return dict[key] ?? nil
        }
    }
    
}
