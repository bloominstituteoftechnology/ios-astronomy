//
//  MarsPhotoFetchOperation.swift
//  Astronomy
//
//  Created by Kevin Stewart on 5/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class PhotoFetchOperation: ConcurrentOperation {
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    private var dataTask = URLSessionDataTask()

    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }

    override func start() {
        state = .isExecuting
        guard let photoURL = marsPhotoReference.imageURL.usingHTTPS else { return }
        let imageURL = photoURL
        var request = URLRequest(url: imageURL)
        request.httpMethod = "GET"

        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                NSLog("error in getting photo: \(error)")
                return
            }

            guard let data = data else { return }

            self.imageData = data
            self.state = .isFinished
        })
        dataTask.resume()

    }
    override func cancel() {
        dataTask.cancel()
    }

}
