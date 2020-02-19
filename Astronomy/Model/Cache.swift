//
//  Cache.swift
//  Astronomy
//
//  Created by Aaron Cleveland on 2/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    private var dictionary: [Key : Value] = [:]

    private let queue = DispatchQueue(label: "Serial Queue")

    func cache(value: Value, for key: Key) {
        queue.async {
            self.dictionary[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        queue.sync {
            return dictionary[key]
        }
    }
}
