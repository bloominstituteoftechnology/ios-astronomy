//
//  Cashe.swift
//  Astronomy
//
//  Created by Sammy Alvarado on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var dic: [Key: Value] = [:]
    let q = DispatchQueue(label: "Qanon")

    func cache(value: Value , for key: Key) {
        q.async {
            self.dic[key] = value
        }
    }

    func getValue(for key: Key) -> Value? {
        q.sync {
            return self.dic[key]
        }
    }

    func removeAllValues() {
        q.async {
            self.dic.removeAll()
        }
    }
}
