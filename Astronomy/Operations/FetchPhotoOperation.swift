//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Linh Bouniol on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    // Store the task so we can use it to cancel it if need be
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        
        // Get url
       guard let url = marsPhotoReference.imageURL.usingHTTPS else { return }
        
        dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error retrieving data: \(error)")
                return
            }
            
            guard let data = data else { return }
            self.imageData = data
            
            defer {
                self.state = .isFinished
            }
        }
        
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
}
