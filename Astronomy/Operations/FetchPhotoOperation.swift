//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Hunter Oppel on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var photoReference: MarsPhotoReference
    var imageData: Data?
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        loadImageDataTask.start()
    }
    
    override func cancel() {
        loadImageDataTask.cancel()
    }
    
    private lazy var loadImageDataTask = BlockOperation {
        print("Fetch started")
        defer {
            self.state = .isFinished
        }
        guard let imageURL = self.photoReference.imageURL.usingHTTPS else { return }
        
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            if let error = error {
                NSLog("Failed to fetch photo with error: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("\(imageURL) returned no data")
                return
            }
            
            self.imageData = data
            print("Fetch finished")
        }.resume()
    }
    
}
