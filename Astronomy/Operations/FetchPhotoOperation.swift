//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Wyatt Harrell on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    var photo: MarsPhotoReference
    var imageData: Data?
    private var dataTask = URLSessionDataTask()
    
    init(photo: MarsPhotoReference) {
        self.photo = photo
    }
    
    override func start() {
        state = .isExecuting
        
        let imageURL = photo.imageURL.usingHTTPS!
        var request = URLRequest(url: imageURL)
        request.httpMethod = "GET"
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                NSLog("Error receiving pokemon image data: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("API responded with no image data")
                return
            }
            
            self.imageData = data
            self.state = .isFinished
            
        })
        dataTask.resume()
    }
    
    override func cancel() {
        dataTask.cancel()
    }
}
