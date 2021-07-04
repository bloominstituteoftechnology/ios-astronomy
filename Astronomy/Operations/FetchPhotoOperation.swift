//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Jonathan Ferrer on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {

    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }

    override func start() {
        state = .isExecuting

        guard let url = marsPhotoReference.imageURL.usingHTTPS else {return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, _, error) in
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error getting image: \(error)")
            }

            defer {
                self.state = .isFinished
            }

            guard let data = data else {
                NSLog("Error with data")
                return
            }

            self.imageData = data
        })
        dataTask?.resume()

    }

    override func cancel() {
        dataTask?.cancel()
    }

    private var dataTask: URLSessionDataTask?
    let marsPhotoReference: MarsPhotoReference
    var imageData: Data?
}
