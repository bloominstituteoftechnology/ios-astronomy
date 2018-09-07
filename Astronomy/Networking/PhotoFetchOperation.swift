//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by De MicheliStefano on 07.09.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class PhotoFetchOperation: ConcurrentOperation {
    
    var photoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(for photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        let imageUrl = photoReference.imageURL.usingHTTPS!
        dataTask = URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching images: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("Could not load data from API")
                return
            }
            
            self.imageData = data
            NSLog("Fetching image \(self.photoReference.id) complete")
            self.state = .isFinished
        }
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
    
}
