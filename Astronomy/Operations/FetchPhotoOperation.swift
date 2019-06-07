//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Conner on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    init(photo: MarsPhotoReference) {
        self.photo = photo
    }
    
    override func start() {
        state = .isExecuting
        
        guard let imageURL = photo.imageURL.usingHTTPS else { return }
        
        task = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            defer { self.state = .isFinished }
            if let error = error {
                NSLog("Error fetching photo in FetchPhotoOperation: \(error)")
                return
            }
            
            if let data = data {
                self.imageData = data
            }

        }
        task.resume()
    }
    
    override func cancel() {
        task.cancel()
    }
    
    // MARK: - Properties
    var photo: MarsPhotoReference
    var imageData: Data?
    var task: URLSessionDataTask = URLSessionDataTask()
}
