//
//  Cache.swift
//  Astronomy
//
//  Created by Hector Steven on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


import UIKit


struct Cache<Key: Hashable, Value> {
	private (set) var cache: [Key: Value] = [:]
	
	/// append to cache
	mutating func cache(value: Value, for key: Key) {
		if let _ = cache[key] { return }
		cache[key] = value
	}
	
	/// return cache for key
	mutating func value(for key: Key) -> Value? {
		return cache[key]
	}
}
