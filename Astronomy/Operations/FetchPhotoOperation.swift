//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Michael Stoffer on 8/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    private (set) var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    let id: Int
    let sol: Int
    let camera: Camera
    let earthDate: Date
    let imageURL: URL
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.id = marsPhotoReference.id
        self.sol = marsPhotoReference.sol
        self.camera = marsPhotoReference.camera
        self.earthDate = marsPhotoReference.earthDate
        self.imageURL = marsPhotoReference.imageURL
        super.init()
    }
    
    override func start() {
        super.start()
        state = .isExecuting
        
        let url = self.imageURL.usingHTTPS!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            
            if let error = error {
                NSLog("Error fetching image data: \(error)")
                return
            }
            self.imageData = data
        }
        task.resume()
        self.dataTask = task
    }
    
    override func cancel() {
        super.cancel()
        if let task = self.dataTask {
            task.cancel()
        }
    }
}
