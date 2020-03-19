//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by David Wright on 3/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    // MARK: - Properties

    var marsPhotoReference: MarsPhotoReference
    
    var imageData: Data?
    
    private lazy var dataTask: URLSessionDataTask? = {
        guard let imageURL = marsPhotoReference.imageURL.usingHTTPS else { return nil }
        //let semaphore = DispatchSemaphore(value: 0)

        return URLSession.shared.dataTask(with: imageURL) { data, _, error in
            defer { self.state = .isFinished }
            guard error == nil else { print("Error fetching image from url: \(error!)"); return }
            guard let data = data else { print("No data returned by data task."); return }
            
            self.imageData = data
            //semaphore.signal()
        }
    }()
    
    // MARK: - Methods
    
    override func cancel() {
        dataTask?.cancel()
    }
    
    override func start() {
        state = .isExecuting
        dataTask?.resume()
    }
    
    // MARK: - Initializers
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
        super.init()
    }
}
