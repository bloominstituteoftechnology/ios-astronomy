//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Michael on 2/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    // MARK: - Properties
    var photoReference: MarsPhotoReference
    
    var imageData: Data?
    
    var dataTask: URLSessionDataTask?
    
    override func start() {
        state = .isExecuting
        
        guard let request = photoReference.imageURL.usingHTTPS else { return }
        dataTask = URLSession.shared.dataTask(with: request) { data, _, error in
            defer {
                self.state = .isFinished
            }
            if let error = error {
                NSLog("Error retrieving photos from server. \(error)")
                return
            }
            guard let data = data else {
                NSLog("Bad Data")
                return
            }
            self.imageData = data
            
        }
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        self.state = .isFinished
    }
    
    init(reference: MarsPhotoReference, session: URLSession = .shared) {
        self.photoReference = reference
        super.init()
    }
}
