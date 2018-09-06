//
//  Cache.swift
//  Astronomy
//
//  Created by Carolyn Lea on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key: Hashable
{
    private var dictionary = [Key : Value]()
    private let queue = DispatchQueue(label: "com.leastudios.Astronomy.CacheQueue")
    
    
    func cache(value: Value, key: Key)
    {
        queue.async {
            self.dictionary[key] = value
        }
    }
    
    func value(key: Key) -> Value?
        
    {
        return queue.sync {
            dictionary[key]
        }
    }
    
    func checkIfCached()
    {
        if dictionary.con
        {
            
        }
    }
}
