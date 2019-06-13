//
//  Cache.swift
//  Astronomy
//
//  Created by Hector Steven on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache <Key: Hashable, Value> {
	private var cache : [Key: Value] = [:]
	
	func cache(value: Value, for key: Key) {
		if let _ = cache[key] { return }
		cache[key] = value
	}
	
	func value(for key: Key) -> Value?{
		return cache[key]
	}
}
