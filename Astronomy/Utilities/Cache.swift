//
//  Cache.swift
//  Astronomy
//
//  Created by Norlan Tibanear on 9/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class Cache<Key: Hashable, Value> {
   
    private var cacheQueue = DispatchQueue(label: "com.LambdaSchool.Astronomy.CacheQueue")
    
    private var dict: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        cacheQueue.async {
            self.dict[key] = value
        }
    }
    
    func value(key: Key) -> Value? {
        return cacheQueue.sync {
            self.dict[key]
        }
    }
    
    
}//
