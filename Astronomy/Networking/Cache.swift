
import UIKit

class Cache <Key: Hashable, Value> {
    
    private var cache: [Key : Value] = [:]
    private let queue = DispatchQueue(label: "com.jonahBergevin.astronomy.cacheQueue")
    
    func cache(_ value: Value, _ forKey: Key) {
        queue.async { self.cache[forKey] = value }
    }
    
    func value(_ forKey: Key) -> Value? {
        return queue.sync{ self.cache[forKey] }
    }
}
