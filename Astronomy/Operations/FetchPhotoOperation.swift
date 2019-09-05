//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Bradley Yin on 9/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    var loadImageDataTask : URLSessionDataTask {
        guard let httpURL = marsPhotoReference.imageURL.usingHTTPS else {
            NSLog("cant make httpURL")
            return URLSessionDataTask()
        }
        return URLSession.shared.dataTask(with: httpURL) { (data, response, error) in
            defer {
                self.state = .isFinished
            }
            if let error = error {
                NSLog("Error doing load image dataTask: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("no data return on load image")
                return
            }
            
            self.imageData = data
            //print("load from internet")
            
        }
    }
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    override func start() {
        state = .isExecuting
        loadImageDataTask.resume()
    }
    
    override func cancel() {
        loadImageDataTask.cancel()
    }
    
}
