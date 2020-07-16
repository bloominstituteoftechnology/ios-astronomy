//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Clayton Watkins on 7/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    var image: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(photo: MarsPhotoReference, session: URLSession = .shared){
        self.image = photo
    }
    
    override func start() {
        state = .isExecuting
        
        guard let requestURL = image.imageURL.usingHTTPS else { return }
        
        dataTask = URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            defer{
                self.state = .isFinished
            }
            
            if let error = error{
                print("Error getting image from url: \(error)")
                return
            }
            
            guard let data = data else{
                print("No data recieved")
                return
            }
            
            self.imageData = data
        }
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        self.state = .isFinished
    }
    
}
