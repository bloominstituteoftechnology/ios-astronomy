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
    
    private var dataTask: URLSessionDataTask?
    
    init(_ photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        
        dataTask = URLSession.shared.dataTask(
            with: photoReference.imageURL,
            completionHandler:
        { possibleData, possibleResponse, possibleError in
            if let error = possibleError {
                print("Error fetching image: \(error)")
                if let response = possibleResponse {
                    print("Response:\n\(response)")
                }
                return
            }
            
            guard let data = possibleData else {
                print("no data!")
                return
            }
            
            self.imageData = data
            
            self.state = .isFinished
        })
    }
}
