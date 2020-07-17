//
//  Cache.swift
//  Astronomy
//
//  Created by Morgan Smith on 7/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cache = [Key : Value]()
    private let queue = DispatchQueue(label: "cacheQueue")

    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        return queue.sync {self.cache[key]}
    }
}
