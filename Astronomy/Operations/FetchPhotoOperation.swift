//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Shawn Gee on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var photoReference: MarsPhotoReference
    var imageData: Data?
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        
        guard let imageURl = photoReference.imageURL.usingHTTPS else { return }
        
        fetchPhotoTask = URLSession.shared.dataTask(with: imageURl) { (data, response, error) in
            defer { self.state = .isFinished }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                print("Invalid response: \(response.statusCode)")
                return
            }
            
            guard let data = data else { return }
            
            self.imageData = data
        }
        
        fetchPhotoTask?.resume()
    }
    
    override func cancel() {
        fetchPhotoTask?.cancel()
    }
    
    private var fetchPhotoTask: URLSessionDataTask?
}
