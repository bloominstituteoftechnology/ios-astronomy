//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Elizabeth Wingate on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {

    // MARK: - Properties
    var photoReference: MarsPhotoReference
    var imageData: Data?

    var dataTask: URLSessionDataTask?

    private let session: URLSession

    init(reference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        self.photoReference = reference
        self.session = session
        super.init()
    }

    override func start() {
        // START
        state = .isExecuting

        guard let request = photoReference.imageURL.usingHTTPS else { return }
        let task = URLSession.shared.dataTask(with: request) { data, _, error in

            defer {
                self.state = .isFinished
            }

            if self.isCancelled {
                return
            }
            
            if let error = error {
                NSLog("Error retrieving \(self.photoReference) photos from server. \(error)")
                return
            }

            guard let data = data else {
                NSLog("Bad Data")
                return
            }
            self.imageData = data
        }
        task.resume()
        self.dataTask = task
    }
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
        //self.state = .isFinished
    }
}
