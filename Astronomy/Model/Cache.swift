//
//  Cache.swift
//  Astronomy
//
//  Created by Hector Steven on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache <Key: Hashable, Value> {
	
	func cache(value: Value, for key: Key) {
		queue.sync {
			if let _ = cache[key] { return }
			cache[key] = value
		}
	}
	
	func value(for key: Key) -> Value?{
		return 	queue.sync { cache[key] }
	}
	
	let queue = DispatchQueue(label: "Cache DispatchQueue")
	private var cache : [Key: Value] = [:]
}
