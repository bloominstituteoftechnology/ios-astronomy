
import Foundation

class Cache<Key, Value> where Key: Hashable {
    
    private var cacheDictionary: [Key: Value] = [:]
    
    // initialize the property with a serial DispatchQueue
    private var queue = DispatchQueue.init(label: "Background Cache Queue")
    // Add items to the cache
    func cache(value: Value, forKey: Key) {
        self.cacheDictionary[forKey] = value
    }
    
    // Remove items from the cache
    func value(forKey: Key) -> Value? {
        
        return queue.sync {
            return self.cacheDictionary[forKey]
        }
        
    }
    
    
}
