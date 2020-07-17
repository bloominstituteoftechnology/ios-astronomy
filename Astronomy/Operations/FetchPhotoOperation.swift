//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Josh Kocsis on 7/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {

    let marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?

    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
        super.init()
    }

    override func start() {
        state = .isExecuting

        guard let imageURL = marsPhotoReference.imageURL.usingHTTPS else { return }

        dataTask = URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, _, error) in
            defer { self.state = .isFinished }

            if let error  = error {
                print("Error with data task: \(error)")
            }

            guard let data = data else {
                print("Error getting data")
                return
            }

            self.imageData = data
        })
        dataTask?.resume()
    }

    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
