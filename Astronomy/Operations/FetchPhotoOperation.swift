//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Gi Pyo Kim on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        super.start()
        
        state = .isExecuting
        guard let url = marsPhotoReference.imageURL.usingHTTPS else { return }
        dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let error = error {
                NSLog("\(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data")
                return
            }
            
            self.imageData = data
            self.state = .isFinished
        })
    }
    
    override func cancel() {
        super.cancel()
        
        dataTask?.cancel()
    }
    
}
