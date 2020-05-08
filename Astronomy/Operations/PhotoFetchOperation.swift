//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Bhawnish Kumar on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class PhotoFetchOperation: ConcurrentOperation {
    
    var marsPhotoReference: MarsPhotoReference
    var imageData: UIImage?
    private var dataTask = URLSessionDataTask()
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
    
    override func start() {
        state = .isExecuting
    }
}
