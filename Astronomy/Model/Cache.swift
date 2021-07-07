//
//  Cache.swift
//  Astronomy
//
//  Created by Jordan Christensen on 10/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key : Hashable {
    private let queue = DispatchQueue(label: "General Cache Queue")
    
    var imageDict: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.imageDict[key] = value
        }
    }
    
    func fetch(key: Key) -> Value? {
        queue.sync {
            if let image = imageDict[key] {
                return image
            }
            return nil
        }
    }
}
