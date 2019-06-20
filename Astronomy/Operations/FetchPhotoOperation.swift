//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Christopher Aronson on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    private var marsPhotoReference: MarsPhotoReference
    var outputImageData: Data?
    var task = URLSessionDataTask()
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        if isCancelled {
            state = .isFinished
            return
        }
        
        state = .isExecuting
        main()
    }
    
    override func cancel() {
        state = .isFinished
    }
    
    override func main() {
        guard let url = marsPhotoReference.imageURL.usingHTTPS else { return }
        
        task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error while trying to fetch image: \(error)")
                self.state = .isFinished
                return
            }
            
            guard let data = data else {
                NSLog("No data sent back from server")
                self.state = .isFinished
                return
            }
            
            self.outputImageData = data
            self.state = .isFinished
        }
        
        task.resume()
    }
}
