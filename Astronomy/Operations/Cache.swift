//
//  Cache.swift
//  Astronomy
//
//  Created by Dahna on 6/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


class Cache<Key: Hashable, Value> {
    
    private var dictionaryStore = [Key: Value]()
    private var queue = DispatchQueue(label: "CacheQueue")
    
    func cache(value: Value, key: Key) {
        queue.async {
            self.dictionaryStore[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync {
            dictionaryStore[key]
        }
    }
    
}
