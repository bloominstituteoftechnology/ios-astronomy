//
//  Cache.swift
//  Astronomy
//
//  Created by Moin Uddin on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation


class Cache<Key, Value> where Key: Hashable {
    
    private(set) var cachedImages = [Key:Value]()
    
    private let queue = DispatchQueue(label: "com.moinuddin.Astronomy.cacheQueue")
    
    func cache(value: Value?, for key: Key) {
        queue.async {
            self.cachedImages[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync {
            return self.cachedImages[key]
        }
    }
}
