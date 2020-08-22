//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Chad Parker on 5/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    let reference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(photoReference: MarsPhotoReference) {
        self.reference = photoReference
    }
    
    override func start() {
        
        state = .isExecuting
        
        guard let imageURL = reference.imageURL.usingHTTPS else { fatalError() }
        dataTask = URLSession.shared.dataTask(with: imageURL) { data, _, error in
            defer { self.state = .isFinished }
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            guard let data = data else {
                fatalError("no data")
            }
            self.imageData = data
        }
        dataTask?.resume()
    }
    
    override func cancel() {
        
        dataTask?.cancel()
    }
}
