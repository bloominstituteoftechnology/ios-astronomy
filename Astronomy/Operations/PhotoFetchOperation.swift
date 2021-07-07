//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Sergey Osipyan on 1/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    private var photoReferences: MarsPhotoReference
    var imageData: Data?
    private var task: URLSessionDataTask?
  
    
    init(photoReferences: MarsPhotoReference) {
        
        self.photoReferences = photoReferences
        super.init()
        
    }
   
    
    override func start() {
        super.start()
        self.state = .isExecuting
        let url = photoReferences.imageURL.usingHTTPS!
        task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                self.cancel()
                NSLog("\(error)")
                return
            }
            
            guard let photoData = data else { return }
            self.imageData = photoData
        }

         

        self.state = .isFinished
        task?.resume()
        }
    
    
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    
    
}
