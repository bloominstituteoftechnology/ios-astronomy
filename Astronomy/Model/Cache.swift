//
//  Cache.swift
//  Astronomy
//
//  Created by Nick Nguyen on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache <Key,Value> where Key: Hashable {
 
    private let serialQueue = DispatchQueue(label: "com.nick.SerialQueue")
    private var cache : [Key: Value] = [:]
    
    func cache(value: Value,for key: Key) {
        serialQueue.async {
             self.cache[key] = value
        }
       
    }
    
    func value(for key: Key) -> Value? {
        serialQueue.sync {
              return self.cache[key]
        }
      
    }
    
    
}
