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
    var task: URLSession?
    
    init(photo: MarsPhotoReference) {
        self.photo = photo
    }
    
    override func start() {
        state = .isExecuting
        
        let imageURL = photo.imageURL.usingHTTPS!
        var request = URLRequest(url: imageURL)
        request.httpMethod = "GET"

        task?.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                NSLog("Error receiving pokemon image data: \(error)")
                self.cancel()
                return
            }
            
            guard let data = data else {
                NSLog("API responded with no image data")
                self.cancel()
                return
            }
            
            self.imageData = data
            self.state = .isFinished
        }).resume()
    }
    
    override func cancel() {
        task?.invalidateAndCancel()
    }
}
