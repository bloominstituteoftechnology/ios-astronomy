//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Lambda_School_Loaner_259 on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    let marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    private var dataTask: URLSessionDataTask { URLSession.shared.dataTask(with: marsPhotoReference.imageURL) { (data, _, error) in
        if let error = error {
            NSLog("Error fetching image data: \(error)")
            return
        }
        self.imageData = data
        }}
    
    init(photoReference: MarsPhotoReference) {
        self.marsPhotoReference = photoReference
    }
    
    override func start() {
        state = .isExecuting
        
        dataTask.resume()
        
        defer { state = .isFinished }
    }
    
    override func cancel() {
        dataTask.cancel()
    }
}
