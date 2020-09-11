//
//  File.swift
//  Astronomy
//
//  Created by BrysonSaclausa on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var dict: [Key: Value] = [:]
    
    let queue = DispatchQueue(label: "QueueCache")
    
    func cache(value: Value, for: Key) {
        queue.async {
            self.dict[`for`] = value
        }
        
     
    }
    
    func getValue(for key: Key) -> Value? {
        queue.sync {
            return self.dict[key]
        }
    }
    
    func remove() {
        queue.async {
            self.dict.removeAll()
        }
    }
    
}
