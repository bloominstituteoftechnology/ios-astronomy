//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Tobi Kuyoro on 09/04/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    private var task: URLSessionDataTask?
    
    let photoReference: MarsPhotoReference
    var imageData: Data?
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        fetchPhoto()
        task?.resume()
    }
    
    override func cancel() {
        fetchPhoto()
        task?.cancel()
    }

    func fetchPhoto() {
        guard let photoURL = photoReference.imageURL.usingHTTPS else { return }
        
        task = URLSession.shared.dataTask(with: photoURL) { data, _, error in
            defer {
                self.state = .isFinished
            }
            
            if let error = error {
                NSLog("Error fetching image: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No image data")
                return
            }
            
            self.imageData = data
        }
        
        task?.resume()
    }
}
