//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Bhawnish Kumar on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class PhotoFetchOperation: ConcurrentOperation {
    
    var photoReference: MarsPhotoReference
    var imageData: Data?
    private var theDataTask = URLSessionDataTask()
    
    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        guard let photoURL = photoReference.imageURL.usingHTTPS else { return }
        let imageURL = photoURL
        var request = URLRequest(url: imageURL)
        request.httpMethod = "GET"
        
        theDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                NSLog("error in getting photo: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            self.imageData = data
            self.state = .isFinished
        })
        theDataTask.resume()
        
    }
   
    override func cancel() {
        theDataTask.cancel()
    }
    
    
   
}
