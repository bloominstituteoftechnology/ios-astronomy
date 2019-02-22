//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Nelson Gonzalez on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    //Add properties to store an instance of MarsPhotoReference for which an image should be loaded as well as imageData that has been loaded. imageData should be optional since it won't be set until after data has been loaded from the network.
    let marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    //You should store the task itself in a private property so you can cancel it if need be.
    private var dataTask: URLSessionDataTask?
    
    //Implement an initializer that takes a MarsPhotoReference
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
        super.init()
    }
    
    
    //Override start(). You should begin by setting state to .isExecuting. This tells the operation queue machinery that the operation has started running.
    override func start() {
        state = .isExecuting
        
        //Create a data task to load the image. You should store the task itself in a private property so you can cancel it if need be.
        
        guard let imageUrl = marsPhotoReference.imageURL.usingHTTPS else {return}
        
        dataTask = URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, _, error) in
            
            //Make sure you set state to .isFinished before exiting the completion closure. This is a good use case for defer.
            defer { self.state = .isFinished }
            
            //In the data task's completion handler, check for an error and bail out if one occurs. Otherwise, set imageData with the received data.
            
            if let error = error {
                print("Error with data task: \(error)")
            }
            
            guard let data = data else {
                print("Error getting data back")
                return
            }
            
            self.imageData = data
   
        })
        
        dataTask?.resume()
    }
    
    //Override cancel(), which will be called if the operation is cancelled. In your implementation, call cancel() on the dataTask.
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
