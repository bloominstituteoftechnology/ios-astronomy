//
//  Cache.swift
//  Astronomy
//
//  Created by Hector Steven on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


struct Cache<Key: Hashable, Value> {
	private (set) var cache: [Key: Value] = [:]

	
	
	mutating func cache(value: Value, for key: Key) {
		cache[key] = value
	}
	
	//value(for:)
}
