//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Angel Buenrostro on 3/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    init(photoRef: MarsPhotoReference) {
        self.photoRef = photoRef
    }
    
    override func start() {
        state = .isExecuting
        
        print("fetch started")
        
        let imageURL = photoRef.imageURL.usingHTTPS
        
        self.task = URLSession.shared.dataTask(with: imageURL!) { (data, _, error) in
            
            defer{
                self.state = .isFinished
            }
            
            if let error = error {
                NSLog("Error fetching image: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned: \(error)")
                return
            }
            print("fetched data: \(data)")
            self.imageData = data
        }
        task!.resume()
    }
    
    override func cancel() {
        print("data task cancelled")
        task?.cancel()
    }
    
    var task: URLSessionDataTask?
    
    let photoRef: MarsPhotoReference
    
    var imageData: Data?
}
