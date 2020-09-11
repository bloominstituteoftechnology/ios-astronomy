//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Cora Jacobson on 9/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    var photoReference: MarsPhotoReference
    var imageData: Data?
    
    private var dataTask: URLSessionDataTask {
        let imageURL = photoReference.imageURL
        let task = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            if let error = error {
                print("Error fetching photo: \(error)")
                return
            } else {
                if let data = data {
                    self.imageData = data
                    return
                }
            }
        }
        return task
    }
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        dataTask.resume()
        state = .isFinished
    }
    
    override func cancel() {
        dataTask.cancel()
        state = .isFinished
    }
    
}
