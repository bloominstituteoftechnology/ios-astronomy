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
    
    lazy private var dataTask: URLSessionDataTask? = {
        guard let url = photoReference.imageURL.usingHTTPS else { return nil }
        let task = URLSession.shared.dataTask( with: url, completionHandler: {
            possibleData, possibleResponse, possibleError in
            
            defer { self.state = .isFinished }
            
            if let error = possibleError as NSError?,
                error.code == -999 {
                return
            } else if let error = possibleError {
                print("Error fetching image: \(error)")
                if let response = possibleResponse {
                    print("Response:\n\(response)")
                }
                return
            }
            
            self.imageData = possibleData
        })
        return task
    }()
    
    
    init(_ photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        state = .isFinished
    }
}
