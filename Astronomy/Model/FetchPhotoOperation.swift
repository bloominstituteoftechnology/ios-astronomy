//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Benjamin Hakes on 1/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//
import Foundation

/**
 This code is represents  a nice "boilerplate" class that makes it easier to implement concurrent/asynchronous Operation subclasses in Swift.
 
 Might want to keep this around as it can be useful for other applications.
 
 */


class FetchPhotoOperation: ConcurrentOperation {
    
    var imageData: Data? = nil
    let photoReference: MarsPhotoReference
    private var dataTask: URLSessionDataTask?
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
        super.init()
    }

    override func start() {
        state = .isExecuting
        guard let url = photoReference.imageURL.usingHTTPS else { return }
        
        dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
//            defer { self.state = .isFinished }
            
            if let error = error {
                NSLog("Error GETing image for \(self.photoReference.id): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data was returned")
                return
            }
            
            self.imageData = data
            return
        })
        dataTask?.resume()
    }
    
    
    override func cancel() {
        dataTask?.cancel()
    }
}
