//
//  Cache.swift
//  Astronomy
//
//  Created by Juan M Mariscal on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache <Key : Hashable, Value> {
        
    // 4. Create a private property that is a dictionary to be used to actually store the cached items. The type of the dictionary should be [Key : Value]. Make sure you initialize it with an empty dictionary.
    private var cacheImageDictionary: [Key : Value] = [:]

    
    // 5. Implement cache(value:, for:) to add items to the cache and value(for:) to return the associated value from the cache.
    func cache(value: Value, for key: Key) {
        cacheImageDictionary[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cacheImageDictionary[key]
    }
    
    
}
