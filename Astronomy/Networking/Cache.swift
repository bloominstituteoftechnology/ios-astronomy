//
//  Cache.swift
//  Astronomy
//
//  Created by Sergey Osipyan on 1/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


class Cache<Key, Value> where Key: Hashable {
    
    private let queue = DispatchQueue.init(label: "Cache storage Queue")
    
    private var tempImageStore: [Key : Value] = [:]
    
    func cache(value: Value, forKey: Key) {
        queue.async {
          
            self.tempImageStore[forKey] = value
    }
    }
    
    func value(forKey: Key) -> Value?  {
        
       
       return queue.sync {
        return tempImageStore[forKey]
        
        }
        
    }
    
}
