//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Dahna on 6/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let id: Int
    let sol: Int
    let camera: Camera
    let earthDate: Date
    let imageURL: URL
        
    private(set) var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.id = marsPhotoReference.id
        self.sol = marsPhotoReference.sol
        self.camera = marsPhotoReference.camera
        self.earthDate = marsPhotoReference.earthDate
        self.imageURL = marsPhotoReference.imageURL
    }
    
    override func start() {
        
        state = .isExecuting
        
        guard let url = self.imageURL.usingHTTPS else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            defer {
                self.state = .isFinished
            }
            if let error = error {
                NSLog("Error Fetching Operation: \(error)")
                return
            }
            if let data = data {
                self.imageData = data
            }
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {

        if self.isCancelled {
            if let task = dataTask {
                task.cancel()
            }
        }
    }
    
    
    
}
