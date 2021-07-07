//
//  Cache.swift
//  Astronomy
//
//  Created by Jocelyn Stuart on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    
    private var queue = DispatchQueue(label: "CacheQueue")
    
    private var cacheDict: [Key: Value] = [:]
    
    func cache(value: Value, for key: Key) {
        queue.sync {
            cacheDict[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
       return queue.sync {
            cacheDict[key]
        }
    }
    
}

/*
 func value(for key: Key, completion: @escaping (Value?) -> ()) {
 queue.sync {
 let val = cacheDict[key]
 completion(val)
 }
 
 }*/

class FetchPhotoOperation: ConcurrentOperation {
    
    var marsPR: MarsPhotoReference?
    
   // var image: URL
    
    var imageData: Data?
    
    init(marsPR: MarsPhotoReference) {
        self.marsPR = marsPR
    }
    
   
    private var dataTask: URLSessionDataTask?
    
    override func start() {
        state = .isExecuting
        
        let dataT = URLSession.shared.dataTask(with: (marsPR?.imageURL.usingHTTPS)!) { (data, _, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            self.imageData = data
            defer {
                self.state = .isFinished
            }
        }
        dataT.resume()
        dataTask = dataT
        
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
    
    
  
    
}


