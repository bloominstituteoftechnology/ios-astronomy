//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by John McCants on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var marsPhotoRef : MarsPhotoReference
    var imageData : Data?
    var task : URLSessionDataTask?
    
    init(marsPhotoRef: MarsPhotoReference) {
        self.marsPhotoRef = marsPhotoRef
        super.init()
    }
    
    
    
    override func start() {
        state = .isExecuting
        guard let imageURL = marsPhotoRef.imageURL.usingHTTPS else {
            return
        }
        self.task = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            
            defer {
                           self.state = .isFinished
                   }
            
            if let error = error {
                print("Error fetching image: \(error)")
                return
            }
            guard let data = data else {
                print("No data returned from fetch")
                return
            }
            
            self.imageData = data
           
        
        }
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        self.state = .isFinished
    }
}
