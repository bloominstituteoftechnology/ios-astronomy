//
//  Cache.swift
//  Astronomy
//
//  Created by Lambda_School_Loaner_268 on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var dict: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        dict[key] = value
    }
    func value(for key: Key) -> Value?  {
        return dict[key] ?? nil
    }
    
}
