//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by brian vilchez on 10/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    let marsPhoto: MarsPhotoReference
    private(set) var imageData: Data?
    private var urlSession: URLSession
    private var dataTask: URLSessionDataTask?
    
  init(marsPhoto: MarsPhotoReference, urlSession: URLSession = URLSession.shared) {
        self.marsPhoto = marsPhoto
        self.urlSession = urlSession
        super.init()
    }
    
    override func start() {
      guard let imageURL = marsPhoto.imageURL.usingHTTPS else {return}
        state = .isExecuting
        let task = urlSession.dataTask(with: imageURL) { (data, _ , error) in
            defer{ self.state = .isFinished }
            if self.isCancelled { return }
            guard let data = data else {return}
            if let error = error {
                NSLog("error fetching image Data for \(self.marsPhoto): \(error)")
            }
            self.imageData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
