//
//  Cache.swift
//  Astronomy
//
//  Created by Cora Jacobson on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    var dictionary: [Key: Value] = [:]
    
    func cache(key: Key, value: Value) {
        queue.async {
            self.dictionary[key] = value
        }
    }
    
    subscript(_ key: Key) -> Value? {
        get {
            queue.sync {
                if let value = dictionary[key] {
                    return value
                } else {
                    return nil
                }
            }
        }
    }
    
    let queue = DispatchQueue(label: "Cache Queue")
}
