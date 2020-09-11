//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by BrysonSaclausa on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    var marsPhotoRef: MarsPhotoReference
    
    init(marsPhotoRef: MarsPhotoReference) {
        self.marsPhotoRef = marsPhotoRef
        super.init()
    }
    
    var imageData: Data?
    
    var task: URLSessionDataTask?
    
    override func start() {
        state = .isExecuting
        
        task = URLSession.shared.dataTask(with: marsPhotoRef.imageURL) { (data, _, error) in
            defer {
                self.state = .isFinished
            }
            
            if let error = error {
                print("\(error)")
                return
            }
            
            guard let data = data else {
                print("no data")
                return
            }
            
            self.imageData = data
            
        }
        task?.resume()
    }
    
    
    override func cancel() {
        task?.cancel()
        self.state = .isFinished
    }
    
}
