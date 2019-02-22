//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Moses Robinson on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
    }
    
    
    
    private var dataTask: URLSessionDataTask?
}
