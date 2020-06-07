//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Stephanie Ballard on 6/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let photoReference: MarsPhotoReference
    // private set means it can only be changed inside of this class
    private(set) var imageData: Data?
    private let session: URLSession
    private var dataTask: URLSessionDataTask?
    
    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        self.photoReference = photoReference
        self.session = session
        super.init()
    }
    
    // customizing manual work saying do this on a background thread, taking charge of threads for this project
    // every operation has two critical funcs that work w/ NSOperation class
    // enum of type state in the concurrent operation class
    override func start() {
        state = .isExecuting
        guard let imageURL = photoReference.imageURL.usingHTTPS else { return }
        let task = session.dataTask(with: imageURL) { (data, _, error) in
            defer { self.state = .isFinished } // wont get to isfinished until the task is finished
            if self.isCancelled { return } // if it gets to iscancelled then it should exist
            if let error = error {
                print("Error fetching data for \(self.photoReference): \(error)")
            }
            // using a data task to turn an image url into data
            guard let data = data else { return }
            self.imageData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel() // cancels the data task
        super.cancel() // cancels the data task and the operation
    }
}
