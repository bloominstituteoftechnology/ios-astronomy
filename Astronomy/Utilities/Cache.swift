//
//  Cache.swift
//  Astronomy
//
//  Created by Angel Buenrostro on 3/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key, Value> where Key : Hashable {
    
    private var cachedPhotos: [Key:Value] = [:]
    
    func cache(value: Value, for key: Key){
        
        queue.async {
            self.cachedPhotos[key] = value
        }
        
    }
    
    func value(for key: Key) -> Value? {
        var value : Value?
        queue.sync {
            value = cachedPhotos[key] 
        }
        //guard let value = cachedPhotos[key] else { return nil }
        
    return value
    }
    
    // Mark: - Properties
    
    private let queue = DispatchQueue(label: "cacheQueue")
    
}
