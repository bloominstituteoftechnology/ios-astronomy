//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Nonye on 6/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let photoReference: MarsPhotoReference
    private(set) var imageData: Data?
    private let session: URLSession
    private var dataTask: URLSessionDataTask?
    
    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        self.photoReference = photoReference
        self.session = session
        super.init()
    }
    // every operation has two critical operations(function) - start & cancel
    override func start() {
        state = .isExecuting
        guard let imageURL = photoReference.imageURL.usingHTTPS else { return }
        let task = session.dataTask(with: imageURL) { (data, _, error) in
            //dont get to the state of isfinished until this task is done
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.photoReference): \(error)")
            }
            guard let data = data else { return }
            self.imageData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
    
}
