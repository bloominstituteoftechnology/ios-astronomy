//
//  Cache.swift
//  Astronomy
//
//  Created by Claudia Contreras on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

// 1. Create a class called Cache. It should be generic with respect to the type it stores, and its keys. e.g. Cache<Key, Value>.
// 2. The generic Key type will need to be constrained to conform to Hashable.
class Cache <Key: Hashable, Value> {
    
    // 3. Create a private property that is a dictionary to be used to actually store the cached items. The type of the dictionary should be [Key : Value]. Make sure you initialize it with an empty dictionary.
    private var cacheDictionary: [Key: Value] = [:]
    
    // 4. Implement cache(value:, for:) to add items to the cache and value(for:) to return the associated value from the cache.
    func cache(value: Value, for key: Key) {
        cacheDictionary[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cacheDictionary[key]
    }
    
}


// 6. In your PhotosCollectionViewController.loadImage(forCell:, forItemAt:) method, before starting a data task, first check to see if the cache already contains data for the given photo reference's id. If it exists, set the cell's image immediately without doing a network request.
// 7. In your network request completion handler, save the just-received image data to the cache so it is available later.
