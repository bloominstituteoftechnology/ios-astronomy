//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by John Kouris on 11/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


class FetchPhotoOperation: ConcurrentOperation {
    
    var imageData: Data?
    var dataTask: URLSessionDataTask?
    
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
        
        guard let url = imageURL.usingHTTPS else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            
            if let error = error {
                print("Error fetching image: \(error)")
                return
            }
            
            self.imageData = data
        }
        
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        super.cancel()
        dataTask?.cancel()
    }
    
}
