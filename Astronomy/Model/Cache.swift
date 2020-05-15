//
//  Cache.swift
//  Astronomy
//
//  Created by Elizabeth Thomas on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

final class Cache<Key: Hashable, Value> {
    private var cacheDictionary: [Key : Value] = [:]
    
    func cache(_ value: Value, forKey key: Key) {
        cacheDictionary.updateValue(value, forKey: key)
    }
    
    func value(forKey key: Key) -> Value? {
        return key.hashValue as? Value
    }
    
}
