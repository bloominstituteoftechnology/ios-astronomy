//
//  FetchOperation.swift
//  Astronomy
//
//  Created by Paul Yi on 2/28/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        
        guard let url = marsPhotoReference.imageURL.usingHTTPS else { return }
        
        dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            defer { self.state = .isFinished }
            
            if let error = error {
                NSLog("Error fetch data task: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data found.")
                return
            }
            
            self.imageData = data
        }
        
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
    
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
}
