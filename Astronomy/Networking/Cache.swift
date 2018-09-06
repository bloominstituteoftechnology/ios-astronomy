//
//  Cache.swift
//  Astronomy
//
//  Created by Linh Bouniol on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class Cache<Key, Value> where Key: Hashable {
    
    // Dictionary that stores cached items
    private var cachedItems: [Key : Value] = [:]
    
    private let queue = DispatchQueue(label: "com.lambdaschool.Astronomy.SerialQueue")
    
    // This is necessary for when you have a generic class/struct, and you want to be able to use something[key or index] syntax
    subscript(_ key: Key) -> Value? {
        return value(for: key)
    }
    
    func cache(value: Value, for key: Key) {
        // Add items to cache
        queue.async {
            self.cachedItems[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
//        return cachedItems[key]
        
        var returnValue: Value?

        // If this is async, it might try to return on line 38, before we have a value
        queue.sync {
            returnValue = self.cachedItems[key]
        }

        return returnValue
    }
    
    /*
     Use GCD or NSOperation to make it more thread-safe that way we can call it anywhere we want and not have to worry about it.
     Only the reading/writing code in the functions are on a different queue, the functions themselves are on the "main" or "whereever" queue
     Once the reading/writing code are done with what they have to do, they go back to the queue the functions are on.
    */
    
}
