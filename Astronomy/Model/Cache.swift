//
//  Cache.swift
//  Astronomy
//
//  Created by David Wright on 3/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    // MARK: - Properties

    private var dictionary: [Key : Value] = [:]
    
    private let queue = DispatchQueue(label: "BackgroundCacheDictionaryQueue")
    
    // MARK: - Methods
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.dictionary[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync {
            return dictionary[key]
        }
    }
}
