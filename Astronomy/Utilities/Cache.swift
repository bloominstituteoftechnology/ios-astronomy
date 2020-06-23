//
//  Cache.swift
//  Astronomy
//
//  Created by Nelson Gonzalez on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    //Create a private queue property and initialize it with a serial DispatchQueue. Give it an appropriate label.
    private let queue = DispatchQueue.init(label: "com.lambdaschool.Astronomy")
    
    var cachedImages: [Key: Value] = [:]
    
    func cache(value: Value?, for theKey: Key) {
        //In cache(value:, for:), dispatch the actual setting of the dictionary key/value pair so that it occurs on the queue.
        queue.async {
            self.cachedImages[theKey] = value
        }
    }
    
    func value(for theKey: Key) -> Value? {
     //In value(for:), use a synchronous dispatch to retrieve the requested value from the dictionary before returning it. Note that DispatchQueue.sync()'s closure can return a value which will subsequently be returned from DispatchQueue.sync() itself. This means you don't need to create a temporary variable outside the dispatched closure.
     return queue.sync {
            cachedImages[theKey]
        }
      
    }
}
