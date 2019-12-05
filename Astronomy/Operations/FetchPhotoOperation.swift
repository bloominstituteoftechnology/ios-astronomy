//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Jon Bash on 2019-12-05.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var photoReference: MarsPhotoReference
    private(set) var imageData: Data?
    
    lazy private var dataTask = URLSession.shared.dataTask(
        with: photoReference.imageURL,
        completionHandler: { possibleData, possibleResponse, possibleError in
            if let error = possibleError {
                print("Error fetching image: \(error)")
                if let response = possibleResponse {
                    print("Response:\n\(response)")
                }
                return
            }
            
            self.imageData = possibleData
    })
    
    
    init(_ photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        defer { state = .isFinished }
        
        dataTask.resume()
    }
    
    override func cancel() {
        dataTask.cancel()
    }
}
