import UIKit

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


var cache = Cache<Int, String>()


cache.cache(value: "1 apple", for: 1)
cache.cache(value: "2 apple", for: 2)
cache.cache(value: "3 apple", for: 3)
cache.cache(value: "4 apple", for: 4)
cache.value(for: 1)

cache
