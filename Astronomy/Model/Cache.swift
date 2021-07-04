//
//  Cache.swift
//  Astronomy
//
//  Created by Jeffrey Santana on 9/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
	
	private var cachedItems = [Key: Value]()
	private let queue = DispatchQueue(label: "MyCacheQueue")
	
	func cache(value: Value, for key: Key) {
		queue.async {
			self.cachedItems.updateValue(value, forKey: key)
		}
	}
	
	func value(for key: Key) -> Value? {
		return queue.sync { () -> Value? in
			cachedItems[key]
		}
	}
}
