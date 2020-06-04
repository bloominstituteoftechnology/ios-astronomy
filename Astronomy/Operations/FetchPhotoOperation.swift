//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Thomas Dye on 5/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let photoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.photoReference = marsPhotoReference
        super.init()
    }
    
    override func start() {
        
        state = .isExecuting
        guard let url = photoReference.imageURL.usingHTTPS else { return }
        dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            print("URL:\(String(describing: url))")
            defer { self.state = .isFinished }
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            if let data = data {
                self.imageData = data
                print("fetched image \(data)")
            }
        }
        dataTask?.resume()
    }
    override func cancel() {
        dataTask?.cancel()
    }
}
