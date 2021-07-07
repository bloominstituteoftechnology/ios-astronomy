//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Moses Robinson on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        
        guard let url = marsPhotoReference.imageURL.usingHTTPS else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error getting image: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data found")
                return
            }
            
            self.imageData = data
            defer { self.state = .isFinished }
        }
        dataTask.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
    
    private var dataTask: URLSessionDataTask?
}
