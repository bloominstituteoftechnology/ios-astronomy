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
        
        guard let photoURL = marsPhotoReference.imageURL.usingHTTPS else { return }
        
        // this data task can(should?) be moved to a lazy var at the class scope
        dataTask = URLSession.shared.dataTask(with: photoURL) { data, _, error in
            defer { self.state = .isFinished }
            
            if let error = error {
                print("Error fetching image data: \(error)")
                return
            }

            if let data = data {
                self.imageData = data
            }
        }
        dataTask?.resume()
    }
    
    override func cancel() {
        print("cancel")
        dataTask?.cancel()
        print("cancelled")
    }
}
