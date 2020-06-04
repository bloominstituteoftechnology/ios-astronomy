//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Daniela Parra on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        guard let imageURL = photoReference.imageURL.usingHTTPS else { return }
        photoDataTask = URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, _, error) in
            if let error = error {
                NSLog("Error fetching image data: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data was returned.")
                return
            }
            
            self.imageData = data
            
            defer {
                self.state = .isFinished
            }
        })
        photoDataTask?.resume()
    }
    
    override func cancel() {
        photoDataTask?.cancel()
    }
    
    var photoDataTask: URLSessionDataTask?
    let photoReference: MarsPhotoReference
    var imageData: Data?
}
