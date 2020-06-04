//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Isaac Lyons on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    let reference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(reference: MarsPhotoReference) {
        self.reference = reference
    }
    
    override func start() {
        state = .isExecuting
        
        dataTask = URLSession.shared.dataTask(with: reference.imageURL.usingHTTPS!) { (data, _, error) in
            if let error = error {
                NSLog("\(error)")
                return
            }
            
            self.imageData = data
            self.state = .isFinished
        }
        
        self.dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
}
