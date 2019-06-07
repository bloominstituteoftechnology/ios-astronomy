import UIKit


struct Cache<Key: Hashable, Value> {
	private (set) var cache: [Key: Value] = [:]
	
	
	/// append to cache
	mutating func cache(value: Value, for key: Key) {
		if let _ = cache[key] {
			return
		}
		
		cache[key] = value
	}
	
	
	mutating func value(for key: Key) -> Value? {
		return cache[key]
	}
}

var list =  ["one", "two", "five"]

var cach = Cache<Int, String>()

cach.cache(value: "String", for: 0)
cach.cache(value: "String231", for: 1)
cach.cache(value: "String!!!", for: 2)
cach.value(for: 5)
