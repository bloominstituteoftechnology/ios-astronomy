//
//  Cache.swift
//  Astronomy
//
//  Created by Ian French on 7/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


class Cache <Key: Hashable, Value> {

    // MARK: - Private Properties

    private var cacheDictionary: [Key: Value] = [:]

    private let queue = DispatchQueue(label: "Cache Queue")

    func cache(value: Value, for key: Key) {
        queue.async {
            self.cacheDictionary[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        queue.sync {
            return cacheDictionary[key]
        }

    }
}
