//
//  Cache.swift
//  Astronomy
//
//  Created by Michael Flowers on 6/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
class Cache<Key: Hashable,Value> {
    //create a private property that is a dictionary to be used to axtually store the cached items
    private var cachedItems: [Key : Value]  = [:]
    
    //create a private queue and intialize it with a serial DispatchQueue
    private let queue = DispatchQueue(label: "com.MikeFlow.Astronomy.cacheQueue")
    
    //push - add items to the cache
    func cache(value: Value, forKey: Key){
        queue.async { //why are we doing this on async???????????????
            //add items to the cachedItems dictionary
            self.cachedItems[forKey] = value
        }
    }
    
    //pop - return the associated value from the cache
    func value(for key: Key) -> Value? {
        //use a synchrounous dispatch to retrieve the requested value from the dictionary before returning it. 
        return queue.sync {
            cachedItems[key] //why don't we need self.?????????????????
        }
    }
}
