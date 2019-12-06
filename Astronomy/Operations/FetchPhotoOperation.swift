//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Rick Wolter on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


class FetchPhotoOperation: ConcurrentOperation {
    
    let photoReference: MarsPhotoReference
    private (set) var imageData: Data?
    private let session: URLSession
    private var dataTask: URLSessionDataTask?
    
    
    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared){
        self.photoReference = photoReference
        self.session = session
        super.init()
    }
    
    
    override func start() {
        state = .isExecuting
        
        guard let imageURL = photoReference.imageURL.usingHTTPS else {return}
        
        let task = session.dataTask(with: imageURL) { (data, _,error) in
            defer {self.state = .isFinished}
            if self.isCancelled {return}
            if let error = error {
                NSLog("Error fetching data for \(self.photoReference): \(error)")
            }
            guard let data = data else {return}
            self.imageData = data
        }
        task.resume()
        dataTask = task
    }
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    
}
