//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Harmony Radley on 6/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


class FetchPhotoOperation: ConcurrentOperation {

    let photoReference: MarsPhotoReference
    var imageData: Data?
    private let session: URLSession
    private var dataTask: URLSessionDataTask?

    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        self.photoReference = photoReference
        self.session = session
        super.init()
    }


    override func start() {
        state = .isExecuting
        guard let imageURL = photoReference.imageURL.usingHTTPS else { return }
        let task = session.dataTask(with: imageURL) { (data, _, error) in
            defer { self.state = .isFinished }
            if let error = error {
                NSLog("Error fetching data for \(self.photoReference), \(error)")
            }
            guard let data = data else { return }
            self.imageData = data
        }
        task.resume()
    }

    override func cancel() {
        dataTask?.cancel()
    }
}
