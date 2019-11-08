//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Fabiola S on 11/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    var imageData: Data?
    var dataTask: URLSessionDataTask?
    
    let id: Int
    let sol: Int
    let camera: Camera
    let earthDate: Date
    let imageURL: URL
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.id = marsPhotoReference.id
        self.sol = marsPhotoReference.sol
        self.camera = marsPhotoReference.camera
        self.earthDate = marsPhotoReference.earthDate
        self.imageURL = marsPhotoReference.imageURL
        super.init()
    }
}
