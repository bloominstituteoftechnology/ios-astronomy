//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Michael Flowers on 6/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference){
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        //this tells the operation queue machinery that the operation has started running
        state = .isExecuting
        
        //create a data task to load the image. You should store the task in a private property so you can cancel it if needed
        guard let url = marsPhotoReference.imageURL.usingHTTPS else { print("FetchPhotoOperation: Error constructing url"); return }
        
         let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("this is the status code for fetching photos: \(response.statusCode) ")
            }
            if let error = error {
                print("Error fetching photos in fetchOp: \(error.localizedDescription), detailed ERROR: \(error)")
                return
            }
            
            guard let data = data else { print("Data received is defunct"); return }
            
            //set our imageData property to data
            self.imageData = data
            
            //make sure to set state to .isFinished before exiting the completion closure.
            defer { self.state = .isFinished}
        }
        dataTask.resume()
    }
    
    //this will be called if the operation is cancelled.
    override func cancel() {
        dataTask?.cancel()
    }
}
