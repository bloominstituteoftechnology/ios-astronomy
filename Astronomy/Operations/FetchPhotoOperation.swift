//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Ian French on 7/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {

    var photoReference: MarsPhotoReference
    var imageData: Data?

    private var loadImageDataTask: URLSessionDataTask?

    init(photoReference: MarsPhotoReference) {
        self.photoReference = photoReference
    }


    override func start() {
        state = .isExecuting

        defer { state = .isFinished }


        guard let imageURL = photoReference.imageURL.usingHTTPS else { return }

        loadImageDataTask = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in

            if let error = error {
                NSLog("Error fetching image: \(error)")
                return
            }

            guard let data = data else {
                NSLog("Error fetching data")
                return
            }

            self.imageData = data
        }

        loadImageDataTask?.resume()
    }

    override func cancel() {
        loadImageDataTask?.cancel()
    }
}
