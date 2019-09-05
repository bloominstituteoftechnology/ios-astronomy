//
//  Cache.swift
//  Astronomy
//
//  Created by Marlon Raskin on 9/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

	private(set) var cachedItems: [Key: Value] = [:]
	let queue = DispatchQueue(label: "CacheSerialQueue")

	func cache(value: Value, for key: Key) {
		queue.async {
			self.cachedItems[key] = value
		}
	}

	func value(for key: Key) -> Value? {
		return queue.sync {
			cachedItems[key]
		}
	}
}
