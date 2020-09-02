//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Nick Nguyen on 3/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class PhotoFetchOperation : ConcurrentOperation {
  
  let photoReference: MarsPhotoReference
  private(set) var imageData : Data?
  private let session : URLSession
  private var dataTask : URLSessionDataTask?
  
  init(photoReference: MarsPhotoReference,session: URLSession = URLSession.shared) {
    self.photoReference = photoReference
    self.session = session
    super.init()
  }
  
  override func start() {
    state = .isExecuting
    let photoURL = photoReference.imageURL.usingHTTPS!
    
    let task = session.dataTask(with: photoURL) { (data, _, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      defer { self.state = .isFinished }
      
      if let data = data {
        self.imageData = data
      }
      
    }
    task.resume()
    dataTask = task
  }
  
  override func cancel() {
    dataTask?.cancel()
    
    super.cancel()
  }
}
