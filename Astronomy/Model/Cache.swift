//
//  Cache.swift
//  Astronomy
//
//  Created by Rob Vance on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key:Hashable, Value> {
    
    private var cacheDictionary: [Key : Value] = [:]
    private let queue = DispatchQueue(label: "serialQueue")
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cacheDictionary[key] = value
            // This sets the limit on how many images is saved in the memory, if it gets to high it dumps the data.
            if self.cacheDictionary.count > 25 {
                self.cacheDictionary.removeAll()
                print("Clearing data")
            }
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            return self.cacheDictionary[key]
        }
    }
}
