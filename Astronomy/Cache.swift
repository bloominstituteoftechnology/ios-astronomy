//
//  Cache.swift
//  Astronomy
//
//  Created by Bobby Keffury on 11/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    let cacheQueue = DispatchQueue(label: "cacheQueue")
    
    var items: [Key: Value] = [:]
    
    func cache(value: Value, for: Key) {
        cacheQueue.sync {
            <#code#>
        }
    }
    
    func value(for: Key) {
        cacheQueue.sync {
            <#code#>
        }
    }
}

