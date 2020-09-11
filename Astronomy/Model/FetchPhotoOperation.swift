//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Rob Vance on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask = URLSessionDataTask()
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
        
        let url = URL(string: "\(marsPhotoReference.imageURL.usingHTTPS!)")
        let request = URLRequest(url: url!)
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            if let error = error {
                preconditionFailure("Error creating dataTask: \(error)")
            }
            
            self.imageData = data
            self.state = .isFinished
        })
        dataTask.resume()
    }
    override func cancel() {
        dataTask.cancel()
    }
}
