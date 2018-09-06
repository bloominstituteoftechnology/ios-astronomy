//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Conner on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    init(photo: MarsPhotoReference) {
        self.photo = photo
        self.task = URLSession.shared
    }
    
    override func start() {
        state = .isExecuting
    }
    
    // MARK: - Properties
    var photo: MarsPhotoReference
    var imageData: Data?
    var task: URLSession
}
