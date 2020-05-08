//
//  Cache.swift
//  Astronomy
//
//  Created by Cameron Collins on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


//Keys - Int, Value - Data
class Cache <Key: Hashable, Value> {
    
    //Cahced Items
    private var items: [Key: Value] = [:]
    
    //MARK: - Methods
    //Add Items
    func cache(value: Value, for key: Key) {
        items[key] = value
    }
    
    //Get Value: Returns an optional Value
    func value(for key: Key) -> Value? {
        return items[key]
    }
    
    
}


