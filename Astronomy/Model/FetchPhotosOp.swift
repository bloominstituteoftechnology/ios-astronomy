//
//  FetchPhotosOp.swift
//  Astronomy
//
//  Created by Kat Milton on 8/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
class FetchPhotoOp: ConcurrentOperation {
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data? = nil
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference){
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        super.start()
        state = .isExecuting
        
        guard let url = marsPhotoReference.imageURL.usingHTTPS else {
            print("FetchPhotoOp: Error using HTTPS")
            return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            defer {
                self.state = .isFinished
            }
            
            if self.isCancelled {
                return
            }
            
            if let error = error {
                print("Error fetching photos: \(error.localizedDescription), detailed ERROR: \(error)")
                return
            }
            
            guard let data = data else {
                print("Bad data")
                return }
       
            self.imageData = data
        }
        
        dataTask.resume()
        self.dataTask = dataTask
    }

    override func cancel() {
        super.cancel()
        dataTask?.cancel()
    }
}
