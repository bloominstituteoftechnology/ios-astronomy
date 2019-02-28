//
//  Cache.swift
//  Astronomy
//
//  Created by Lambda_School_Loaner_34 on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    //Create a private queue property and initialize it with a serial DispatchQueue.
    private var qCache = DispatchQueue(label: "com.Frulwinn.Astronomy.Cache")
    
    private var items: [Key: Value] = [:]
    
    //Implement cache(value:, for:) and value(for:) methods to add items to the cache and remove them, respectively.
    //I don't really understand this.
    
    func cache(value: Value, for key: Key) {
        qCache.async {
            self.items[key] = value
        }
    }
    //remove
    func value(for key: Key) -> Value?{
        return qCache.sync {
            items[key]
        }
    }
}
