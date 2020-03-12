//
//  Cache.swift
//  Astronomy
//
//  Created by Chris Gonzales on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


class Cache<Key, Value> where Key: Hashable {
    
    private var cacheDictionary: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cacheDictionary[key] = value
    }

    
}
