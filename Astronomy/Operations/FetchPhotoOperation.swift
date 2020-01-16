//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Chad Rutherford on 1/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    let reference: MarsPhotoReference
    var imageData: Data?
    var task: URLSessionDataTask?
    
    init(reference: MarsPhotoReference) {
        self.reference = reference
    }
    
    override func start() {
        self.state = .isExecuting
        guard let url = reference.imageURL.usingHTTPS else { return }
        task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            defer {
                self.state = .isFinished
            }
            
            if let _ = error {
                return
            }
            
            guard let data = data else { return }
            self.imageData = data
        }
        task?.resume()
    }
    
    override func cancel() {
        if let task = task {
            task.cancel()
        }
    }
}
