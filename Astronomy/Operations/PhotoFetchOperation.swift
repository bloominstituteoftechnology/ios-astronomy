//
//  PhotFetchOperation.swift
//  Astronomy
//
//  Created by Kenny on 2/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class PhotoFetchOperation: ConcurrentOperation {
    //=======================
    // MARK: - Properties
    private var photoRef: MarsPhotoReference
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(ref: MarsPhotoReference, session: URLSession = .shared) {
        self.photoRef = ref
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        fetchPhoto()
        dataTask?.resume()
    }
    
    override func cancel() {
        state = .isFinished
        dataTask?.cancel()
    }
    
    func fetchPhoto() {
        guard let url = photoRef.imageURL.usingHTTPS else { return }
        dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            defer {
                self.state = .isFinished
            }
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            self.imageData = data
        }
    }
}
