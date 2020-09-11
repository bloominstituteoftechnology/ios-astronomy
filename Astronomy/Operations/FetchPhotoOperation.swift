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
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    private var dataTask: URLSessionDataTask?
    
    override func start() {
        state = .isExecuting
        guard let url = photoReference.imageURL.usingHTTPS else {
            state = .isFinished
            return
        }
        let request = URLRequest(url: url)
        dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            defer {
                self.state = .isFinished
            }
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
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        state = .isFinished
    }
    
}
