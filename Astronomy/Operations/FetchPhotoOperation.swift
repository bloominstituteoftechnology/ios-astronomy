//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Moin Uddin on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var photo: MarsPhotoReference
    var task: URLSessionDataTask = URLSessionDataTask()
    var imageData: Data?
    
    init(photo: MarsPhotoReference) {
        self.photo = photo
    }
    
    override func start() {
        state = .isExecuting
        guard let imageUrl = photo.imageURL.usingHTTPS else { return }
        task = URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
            if let error = error {
                NSLog("Error getting image \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("Error returning data \(error)")
                return
            }
            self.imageData = data
        }
        task.resume()
    }
    
    override func cancel() {
        task.cancel()
    }
    
    
}
