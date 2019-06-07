import UIKit


struct Cache<Key: Hashable, Value> {
	private (set) var cache: [Key: Value] = [:]
	
	
	
	mutating func cache(value: Value, for key: Key) {
		if let _ = cache[key] {
			return
		}
		
		cache[key] = value
	}
	
	//value(for:)
}

var list =  ["one", "two", "five"]

var cach = Cache<Int, String>()

cach.cache(value: "String", for: 0)
cach.cache(value: "String", for: 1)
cach.cache(value: "String", for: 2)
cach
