//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Sammy Alvarado on 9/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FethchPhotoOperation: ConcurrentOperation {

    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    var task: URLSessionDataTask?

    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
        super.init()
    }

    override func start() {
        state = .isExecuting

        guard let imageURL = marsPhotoReference.imageURL.usingHTTPS  else {
            return
        }

        task = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            defer {
                self.state = .isFinished
            }

            if let error = error {
                print("Failed to get imageURL \(error)")
                return
            }

            guard let data = data else {
                print("no data")
                return
            }

            self.imageData = data

        }
        task?.resume()
    }

    override func cancel() {
        task?.cancel()
        self.state = .isFinished
    }
}
