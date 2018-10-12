//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Ilgar Ilyasov on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    // Properties
    var marsPhoto: MarsPhotoReference!
    var imageData: Data?
    var task: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhoto = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        guard let url = marsPhoto.imageURL.usingHTTPS else { return }
        
        task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            defer { self.state = .isFinished }

            if error != nil {
                NSLog("Error performing data task")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                return
            }
            
            self.imageData = data
        }
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
    }
    
}
