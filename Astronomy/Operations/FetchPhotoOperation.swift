//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Simon Elhoej Steinmejer on 06/09/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation
{
    var photoReference: MarsPhotoReference
    var imageData: Data?
    var dataTask: URLSessionDataTask?
    
    init(photoReference: MarsPhotoReference)
    {
        self.photoReference = photoReference
        super.init()
    }
    
    override func start()
    {
        state = .isExecuting
        
        let url = photoReference.imageURL.usingHTTPS!
        dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if self.isCancelled
            {
                return
            }
            
            if let error = error
            {
                return
            }
            
            self.imageData = data
            self.state = .isFinished
            
        }
        dataTask?.resume()
    }
    
    override func cancel()
    {
        dataTask?.cancel()
    }
}




