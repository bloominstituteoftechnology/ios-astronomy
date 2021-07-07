//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Chris Gonzales on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


class FetchPhotoOperation: ConcurrentOperation {
    
    
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        
        let referenceURL = marsPhotoReference.imageURL.usingHTTPS
        
        guard let imageURL = referenceURL else { return }
        
        dataTask = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            defer { self.state = .isFinished }
            
            if let error = error {
                NSLog("Error loading image URL: \(error)")
                return
            }
            guard let data = data else {
                NSLog("No data returned")
                return
            }
            self.imageData = data

        }
        guard let dataTask = dataTask else { return }
        dataTask.resume()
    }
    
    override func cancel() {
        guard let dataTask = dataTask else { return }
        dataTask.cancel()
    }

}
