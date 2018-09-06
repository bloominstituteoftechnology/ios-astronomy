//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Jeremy Taylor on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    let photoReference: MarsPhotoReference
    var imageData: Data?
    private var task = URLSessionDataTask()
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
         guard let url = photoReference.imageURL.usingHTTPS else { return }
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let error = error {
                NSLog("Error downloading image: \(error)")
            }
            guard let data = data else { return }
            self.imageData = data
            defer {
                state = .isFinished
            }
        })
    }
    
    override func cancel() {
        task.cancel()
    }
}
