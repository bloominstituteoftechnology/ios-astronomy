//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Jorge Alvarez on 2/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

/// Subclassed from ConcurrentOperation. C.O. is a nice "boilerplate" class that makes it easier to implement concurrent/asynchronous Operation subclasses in Swift
class FetchPhotoOperation: ConcurrentOperation {
    
    // MARK: - Properties
    var photoReference: MarsPhotoReference
    
    /// Optional since it won't be set until AFTER data has been loaded from the network
    var imageData: Data?
    
    /// For loading an image. Stored as property so it can be cancelled if need be
    var dataTask: URLSessionDataTask?
    
    private let session: URLSession
    
    /// Now inits the URLSession
    init(reference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        self.photoReference = reference
        self.session = session
        super.init()
    }
    
    /// Begins by setting state to .isExecuting. This tells the operation queue machinery that the operation has started running.
    override func start() {
        // START
        state = .isExecuting
        
        guard let request = photoReference.imageURL.usingHTTPS else { return }
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            
            // Before exiting the closure, set state to .isFinished.
            defer {
                self.state = .isFinished
            }
            
            // Back out if canceled
            if self.isCancelled {
                return
            }
            
            // Back out if there is an error
            if let error = error {
                NSLog("Error retrieving \(self.photoReference) photos from server. \(error)")
                return
            }
            
            // Check if there's actually data
            guard let data = data else {
                NSLog("Bad Data")
                return
            }
            // Success
            self.imageData = data
        }
        task.resume()
        self.dataTask = task
    }
    
    /// Called if the operation is cancelled. Cancelling on the datatask
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
        //self.state = .isFinished
    }
}
