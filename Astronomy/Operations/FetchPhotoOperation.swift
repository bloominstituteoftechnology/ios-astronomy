//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by scott harris on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    let photoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.photoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        let url = photoReference.imageURL.usingHTTPS
        guard let URL = url else {
            print("invalid url")
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: URL) { (data, response, error) in
            defer {
                self.state = .isFinished
            }
            
            if let error = error {
                NSLog("Error received from network: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                NSLog("Unsuccessful status code received, status code was: \(response.statusCode)")
                return
            }
            
            guard let data = data else {
                NSLog("No data received")
                return
            }
            
            self.imageData = data

        }
        
        dataTask?.resume()
        
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
    
}
