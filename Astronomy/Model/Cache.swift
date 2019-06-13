//
//  Cache.swift
//  Astronomy
//
//  Created by Hayden Hastings on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync { cache[key] }
    }
    
    private var cache = [Key: Value]()
    private let queue = DispatchQueue(label: "Hayden_Hastings.Mars")
}
