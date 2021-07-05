//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Austin Cole on 1/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    init(photoReference: MarsPhotoReference) {
        super.init()
        self.photoReference = photoReference
    }
    override func start() {
        super.start()
    self.state = .isExecuting
        dataTaskSession = URLSession.shared.dataTask(with: (photoReference?.imageURL.usingHTTPS)!) { (data, _, error) in
            if let error = error {
                fatalError("error initiating data task in FetchPhotoOperation.start: \(error)")
            }
            guard let data = data else { fatalError("error initiating data task in FetchPhotoOperation.start: \(error)") }
            self.imageData = data
            self.state = .isFinished
        }
        dataTaskSession?.resume()
    }
    override func cancel(){
        super.cancel()
        dataTaskSession?.cancel()
    }
    
    //MARK: Properties
    
    var photoReference: MarsPhotoReference?
    var imageData: Data?
    var dataTaskSession: URLSessionDataTask?
    
}
