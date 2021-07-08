//
//  Cache.swift
//  Astronomy
//
//  Created by Sean Hendrix on 11/29/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit


class Cache<Key: Hashable, Value> {
    
    private var cache = [Key : Value]()
    private let queue = DispatchQueue(label: "que")
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        var x: Value?
        queue.sync {
            x = cache[key]
        }
        return x
    }
}
