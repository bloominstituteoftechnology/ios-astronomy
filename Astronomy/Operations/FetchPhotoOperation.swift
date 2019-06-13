//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Kobe McKee on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
 
    private var imageData: Data?
    private var dataTask: URLSessionDataTask?
    private let session: URLSession
    
    
    let id: Int
    let sol: Int
    let camera: Camera
    let earthDate: Date
    let imageURL: URL
    
    init(marsPhotoReference: MarsPhotoReference, session: URLSession) {
        self.id = marsPhotoReference.id
        self.sol = marsPhotoReference.sol
        self.camera = marsPhotoReference.camera
        self.earthDate = marsPhotoReference.earthDate
        self.imageURL = marsPhotoReference.imageURL
        self.session = session
        super.init()
    }
    
    
    override func start() {
        state = .isExecuting
        
        let url = imageURL.usingHTTPS!
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            
            if let error = error {
                NSLog("Error fetching image data: \(error)")
                return
            }
            self.imageData = data
            
        }
        task.resume()
        dataTask? = task
    }
    
    
    override func cancel() {
        dataTask?.cancel()
    }
    

    
    
    
    
    
}
