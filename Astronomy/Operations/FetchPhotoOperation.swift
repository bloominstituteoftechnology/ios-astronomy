//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Morgan Smith on 7/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {

    let photoReference: MarsPhotoReference

    private let session: URLSession

    private(set) var imageData: Data?

    private var dataTask: URLSessionDataTask?

    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared) {
           self.photoReference = photoReference
           self.session = session
           super.init()
       }

       override func start() {
           state = .isExecuting
           let url = photoReference.imageURL.usingHTTPS!

           let task = session.dataTask(with: url) { (data, response, error) in
               defer { self.state = .isFinished }
               if self.isCancelled { return }
               if let error = error {
                   NSLog("Error fetching data for \(self.photoReference): \(error)")
                   return
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
