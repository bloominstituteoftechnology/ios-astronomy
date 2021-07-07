//
//  Cache.swift
//  Astronomy
//
//  Created by Simon Elhoej Steinmejer on 06/09/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value>
{
    private var dictionary: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "dk.SimonElhoej.GCD.SerialQueue")
    
    func addToCache(value: Value, key: Key)
    {
        queue.async {
            self.dictionary[key] = value
        }
    }
    
    func value(for key: Key) -> Value?
    {
        return queue.sync { return dictionary[key] /* value */ }
    }
    
    func imageIsCached(id: Key) -> Bool
    {
        for (key, _) in dictionary
        {
            if key == id
            {
                return true
            }
        }
        
        return false
    }
}
