//
//  Cache.swift
//  Astronomy
//
//  Created by Jonathan Ferrer on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    private var store: [Key: Value] = [:]

    let queue = DispatchQueue(label: "CacheQueue")

    func cache(value: Value, for key: Key) {
        queue.async {
            self.store[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        return queue.sync {
            store[key]
        }
    }
}
