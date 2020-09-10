//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Norlan Tibanear on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
   
    var photoReference: MarsPhotoReference
    var imageData: Data?
    
    private var dataTask = URLSessionDataTask()
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    
    override func start() {
        state = .isExecuting
        
        guard let photoURL = photoReference.imageURL.usingHTTPS else { return }
        let imageURL = photoURL
        
        var request = URLRequest(url: imageURL)
        request.httpMethod = "GET"
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data,_, error) in
            
            if let error = error {
                NSLog("Error getting image: \(error)")
                self.state = .isFinished
                return
            }
            
            guard let data = data else { return }
            self.imageData = data
            self.state = .isFinished
            
        })
        dataTask.resume()
        
    }//
    
    override func cancel() {
        dataTask.cancel()
    }
    
    
}//
