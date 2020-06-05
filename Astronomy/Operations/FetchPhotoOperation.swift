//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Claudia Contreras on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    // 1. Add properties to store an instance of MarsPhotoReference for which an image should be loaded as well as imageData that has been loaded. imageData should be optional since it won't be set until after data has been loaded from the network.
    var photoReference: MarsPhotoReference
    var imageData: Data?
    
    private var loadImageDataTask: URLSessionDataTask?
    
    // 2. Implement an initializer that takes a MarsPhotoReference.
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    // 3. Override start(). You should begin by setting state to .isExecuting. This tells the operation queue machinery that the operation has started running.
    override func start() {
        state = .isExecuting
        
        // 6. Make sure you set state to .isFinished before exiting the completion closure. This is a good use case for defer.
        defer { state = .isFinished }
        
        // 4. Create a data task to load the image. You should store the task itself in a private property so you can cancel it if need be.
        guard let imageURL = photoReference.imageURL.usingHTTPS else { return }
        
        loadImageDataTask = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            // 5. In the data task's completion handler, check for an error and bail out if one occurs. Otherwise, set imageData with the received data.
            if let error = error {
                NSLog("Error fetching image: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("Error fetching data")
                return
            }
            
            self.imageData = data
        }
        
        loadImageDataTask?.resume()
    }
    
    // 7. Override cancel(), which will be called if the operation is cancelled. In your implementation, call cancel() on the dataTask.
    override func cancel() {
        loadImageDataTask?.cancel()
    }
}
