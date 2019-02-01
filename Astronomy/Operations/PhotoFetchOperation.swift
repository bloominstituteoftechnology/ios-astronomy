//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Sergey Osipyan on 1/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let marsPhotoReference: MarsPhotoReference
    var url: URL
    private var task: URLSessionDataTask?
    
    init(marsPhotoReference: MarsPhotoReference, url: URL) {
        self.marsPhotoReference = marsPhotoReference
        self.url = url
        super.init()
    }
    
    
    override func start() {
        super.start()
        state = .isExecuting
//        task = URLSessionDataTask(with: url, complition: { (data, _, error) in
//
//
//
//        state = .isFinished
//
//        })
//        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    
    
}
