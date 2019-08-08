//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Sean Acres on 8/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class PhotoFetchOperation: ConcurrentOperation {
    var photoReference: MarsPhotoReference
    var imageData: Data?
    
    private var dataTask: URLSessionDataTask = URLSessionDataTask()
    
    // MARK: Functions
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        if let url = photoReference.imageURL.usingHTTPS {
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                defer {
                    self.state = .isFinished
                }
                
                if let error = error {
                    NSLog("Error getting image data from url: \(error)")
                    return
                }
                
                guard let data = data else { return }
                self.imageData = data
                
            }
            
            task.resume()
            self.dataTask = task
        }
    }
    
    override func cancel() {
        dataTask.cancel()
    }
}
