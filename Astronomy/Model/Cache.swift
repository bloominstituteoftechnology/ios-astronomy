//
//  Cache.swift
//  Astronomy
//
//  Created by Clayton Watkins on 7/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value>{
    
    private var storedCache:[Key : Value] = [:]
    
    func storeInCache(value: Value, for key: Key){
        self.storedCache[key] = value
    }
    
    func getValue(for key: Key) -> Value?{
        guard let storedValue = self.storedCache[key] else { return nil}
        return storedValue
    }
    
}
