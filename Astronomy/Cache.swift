import Foundation

class Cache<Key, Value> where Key: Hashable {
    
    private var cacheDict: [Key: Value] = [:]
    private let q = DispatchQueue(label: "Cache<\(Value.self), \(Value.self)>")
    
    func cache(value: Value, forKey: Key) {
        
        q.async {
            self.cacheDict[forKey] = value
        }
    }
    
    func value(forKey: Key) -> Value? {
       
        var returnValue: Value!
        q.sync {
            returnValue = cacheDict[forKey]
        }
        return returnValue
    }
}
