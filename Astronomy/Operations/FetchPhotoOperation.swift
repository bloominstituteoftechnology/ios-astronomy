//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Farhan on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    var photoReference: MarsPhotoReference
    var imageData: Data?
    
    var dataTask: URLSessionDataTask {
        return URLSession.shared.dataTask(with: photoReference.imageURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error Initializing DataTask: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("Data Corrupted")
                return
            }
            
            self.imageData = data
            
            defer {
                self.state = .isFinished
            }
        }
    }
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        dataTask.resume()
    }
    
    override func cancel() {
        dataTask.cancel()
    }
    
    
}
