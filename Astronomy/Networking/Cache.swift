//
//  Cache.swift
//  Astronomy
//
//  Created by Shawn Gee on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    // MARK: - Public

    func cache(_ value: Value, ofSize bytes: Int, for key: Key) {
        queue.async {
            self.store[key] = (value, bytes)
            self.chronologicalKeys.append(key)
            
            self.storeSize += bytes
            if self.storeSize > 10_000 {
                self.evictOldEntries()
            }
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync { store[key]?.value }
    }
    
    // MARK: - Private
    
    private var store: [Key: (value: Value, size: Int)] = [:]
    private var chronologicalKeys: [Key] = []
    private let queue = DispatchQueue(label: "Cache Queue")
    private var storeSize = 0 // Bytes
    
    private func evictOldEntries() {
        while storeSize > 5_000 {
            guard !chronologicalKeys.isEmpty else { break }
            let key = chronologicalKeys.removeFirst()
            guard let value = store.removeValue(forKey: key) else { continue }
            storeSize -= value.size
        }
    }
}
