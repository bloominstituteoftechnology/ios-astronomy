//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Hayden Hastings on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    override func start() {
        state = .isExecuting
        let url = photoReference.imageURL.usingHTTPS!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.photoReference): \(error)")
                return
            }
            
            self.imageData = data
        }
        
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        self.photoReference = photoReference
        self.session = session
        super.init()
    }
    
    let photoReference: MarsPhotoReference
    private(set) var imageData: Data?
    private let session: URLSession
    private var dataTask: URLSessionDataTask?
}
