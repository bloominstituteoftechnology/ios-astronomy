//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by morse on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        defer { self.state = .isFinished }
        
        let photoURL = marsPhotoReference.imageURL
        
        dataTask = URLSession.shared.dataTask(with: photoURL) { data, _, error in
            
            if let error = error {
                print("Error fetching image data: \(error)")
                return
            }

            if let data = data {
                self.imageData = data
            }
        }
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
}
