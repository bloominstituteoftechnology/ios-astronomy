//
//  Cache.swift
//  Astronomy
//
//  Created by Elizabeth Wingate on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key,Value> where Key: Hashable {

    private var cachedDictionary: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "PhotoCacheQueue")
    
    func addCache(value: Value, for key: Key) {
        queue.async {
            self.cachedDictionary[key] = value
        }
    }
    func value(for key: Key) -> Value? {
        queue.sync {
            return cachedDictionary[key]
        }
    }
}
