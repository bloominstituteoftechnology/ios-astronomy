//
//  Cache.swift
//  Astronomy
//
//  Created by Lydia Zhang on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
class Cache<Key: Hashable, Value> {
    
    private var dic: [Key : Value] = [:]
    
    func cache(value: Value, for key: Key) {
        dic[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return dic[key]
    }
}
