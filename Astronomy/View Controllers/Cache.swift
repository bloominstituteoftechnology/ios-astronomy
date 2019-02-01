
import Foundation

class Cache<Key, Value> where Key: Hashable {
    
    private var cacheDictionary: [Key: Value] = [:]
    
    // Add items to the cache
    func cache(value: Value, forKey: Key) {
        self.cacheDictionary[forKey] = value
    }
    
    // Remove items from the cache
    func value(forKey: Key) -> Value? {
        return cacheDictionary[forKey]
    }
    
    
}
