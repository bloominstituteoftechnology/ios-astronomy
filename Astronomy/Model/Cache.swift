import Foundation

class Cache<Key, Value> where Key: Hashable {
    private let queue = DispatchQueue(label: "cacheQueue")
    private var cacheDictionary: [Key: Value] = [:] {
        didSet {
            print(cacheDictionary)
        }
    }
    
    func cache(forKey key: Key , forValue value: Value ) {
        queue.sync() {
        cacheDictionary[key] = value
        }
    }
    func value(for key: Key ) -> Value? {
        var lookUpValue: Value?
        queue.sync() {
            if let value = cacheDictionary[key] {
                lookUpValue = value
            }
        }
        return lookUpValue
    }
}
